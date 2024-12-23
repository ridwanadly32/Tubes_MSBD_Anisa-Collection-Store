<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use App\Models\Product;
use App\Models\Category;
use App\Models\Brand;
use App\Models\ViewDiscountedProduct;
use Illuminate\Support\Facades\DB;  

use Illuminate\Support\Str;

class ProductController extends Controller
{
    /**
     * Display a listing of the resource.
     *
     * @return \Illuminate\Http\Response
     */
    public function index()
    {
        // Memanggil fungsi CountActiveProducts dari database
        $activeProductCount = DB::select('SELECT CountActiveProducts() AS active_product_count')[0]->active_product_count ?? 0;

        // Ambil produk dari database
        $products = Product::paginate(10);

        // Kirimkan data ke view
        return view('backend.product.index', compact('products', 'activeProductCount'));
    }

    public function getStockByCategory(Request $request)
    {
        // Ambil kategori untuk dropdown
        $categories = Category::where('status', 'active')->orderBy('title', 'ASC')->get();
    
        // Ambil ID kategori dari request atau set default NULL
        $category_id = $request->input('category_id') ?? null;
    
        // Inisialisasi hasil produk kosong
        $products = [];
    
        if ($category_id) {
            // Eksekusi stored procedure jika kategori dipilih
            $products = \DB::select('CALL get_stock_by_category(?)', [$category_id]);
        }
    
        // Kirimkan $categories dan $products ke view
        return view('backend.product.stock', [
            'categories' => $categories,
            'products' => $products,
            'categoryId' => $category_id
        ]);
    }
    

    public function discountedProducts()
    {
        // Ambil data dari view 'view_discounted_products' dengan pagination
        $discountedProducts = ViewDiscountedProduct::orderBy('discounted_price', 'ASC')->paginate(10);
    
        // Kirim data ke view
        return view('backend.product.discounted-products', compact('discountedProducts'));
    }
    
    

    
    

    public function getStockByCategoryForm()
    {
        // Mengambil semua kategori dari model Category
        $categories = Category::where('status', 'active')->orderBy('title', 'ASC')->get();
    
        // Kirimkan default null untuk categoryId
        return view('backend.product.stock', [
            'categories' => $categories,
            'categoryId' => null
        ]);
    }
    
    
    public function getBestSellingProducts()
    {
        // Panggil stored procedure menggunakan DB::select
        $bestSellingProducts = DB::select('CALL get_best_selling_products()');

        // Kirim data ke view
        return view('backend.product.best-selling', compact('bestSellingProducts'));
    }

    public function getDiscountedPrice($productId)
{
    $product = Product::find($productId);
    
    if ($product) {
        // Panggil fungsi stored di database
        $discountedPrice = DB::select('SELECT calculate_discounted_price(?, ?) AS discounted_price', [
            $product->price,
            $product->discount
        ]);
        
        // Kembalikan hasil
        return response()->json([
            'original_price' => $product->price,
            'discount' => $product->discount,
            'discounted_price' => $discountedPrice[0]->discounted_price ?? 0
        ]);
    }
    
    return response()->json(['error' => 'Product not found'], 404);
}

public function getActiveProductCount()
{
    // Menjalankan stored function CountActiveProducts
    $result = DB::select('SELECT CountActiveProducts() AS active_product_count');

    // Menyimpan hasil ke dalam variabel
    $activeProductCount = $result[0]->active_product_count ?? 0;

    // Mengembalikan hasil ke view
    return view('backend.product.index', compact('activeProductCount'));
}



    
    


    /**
     * Show the form for creating a new resource.
     *
     * @return \Illuminate\Http\Response
     */
    public function create()
    {
        $brand = Brand::get();
        $category = Category::all(); // Mengambil semua kategori
        return view('backend.product.create')->with('categories', $category)->with('brands', $brand);
    }
    

    /**
     * Store a newly created resource in storage.
     *
     * @param  \Illuminate\Http\Request  $request
     * @return \Illuminate\Http\Response
     */
    public function store(Request $request)
    {
        // return $request->all();
        $this->validate($request,[
            'title'=>'string|required',
            // 'summary'=>'string|required',
            'description'=>'string|required',
            'photo'=>'string|required',
            'size'=>'nullable',
            'stock'=>"required|numeric",
            'cat_id'=>'required|exists:categories,id',
            'brand_id'=>'nullable|exists:brands,id',
            // 'child_cat_id'=>'nullable|exists:categories,id',
            'status'=>'required|in:active,inactive',
            'condition'=>'required|in:default,new,hot',
            'price'=>'required|numeric',
            'discount'=>'nullable|numeric'
        ]);

        $data=$request->all();
        $slug=Str::slug($request->title);
        $count=Product::where('slug',$slug)->count();
        if($count>0){
            $slug=$slug.'-'.date('ymdis').'-'.rand(0,999);
        }
        $data['slug']=$slug;
        // $data['is_featured']=$request->input('is_featured',0);
        $size=$request->input('size');
        if($size){
            $data['size']=implode(',',$size);
        }
        else{
            $data['size']='';
        }
        // return $size;
        // return $data;
        $status=Product::create($data);
        if($status){
            request()->session()->flash('success','Product Successfully added');
        }
        else{
            request()->session()->flash('error','Please try again!!');
        }
        return redirect()->route('product.index');

    }

    /**
     * Display the specified resource.
     *
     * @param  int  $id
     * @return \Illuminate\Http\Response
     */
    public function show($id)
    {
        //
    }

    /**
     * Show the form for editing the specified resource.
     *
     * @param  int  $id
     * @return \Illuminate\Http\Response
     */
    public function edit($id)
    {
        $brand=Brand::get();
        $product=Product::findOrFail($id);
        $category = Category::all(); // Mengambil semua kategori
        $items=Product::where('id',$id)->get();
        // return $items;
        return view('backend.product.edit')->with('product',$product)
                    ->with('brands',$brand)
                    ->with('categories',$category)->with('items',$items);
    }

    /**
     * Update the specified resource in storage.
     *
     * @param  \Illuminate\Http\Request  $request
     * @param  int  $id
     * @return \Illuminate\Http\Response
     */
    public function update(Request $request, $id)
    {
        $product=Product::findOrFail($id);
        $this->validate($request,[
            'title'=>'string|required',
            // 'summary'=>'string|required',
            'description'=>'string|required',
            'photo'=>'string|required',
            'size'=>'nullable',
            'stock'=>"required|numeric",
            'cat_id'=>'required|exists:categories,id',
            // 'child_cat_id'=>'nullable|exists:categories,id',
            // 'is_featured'=>'sometimes|in:1',
            'brand_id'=>'nullable|exists:brands,id',
            'status'=>'required|in:active,inactive',
            'condition'=>'required|in:default,new,hot',
            'price'=>'required|numeric',
            'discount'=>'nullable|numeric'
        ]);

        $data=$request->all();
        // $data['is_featured']=$request->input('is_featured',0);
        $size=$request->input('size');
        if($size){
            $data['size']=implode(',',$size);
        }
        else{
            $data['size']='';
        }
        // return $data;
        $status=$product->fill($data)->save();
        if($status){
            request()->session()->flash('success','Product Successfully updated');
        }
        else{
            request()->session()->flash('error','Please try again!!');
        }
        return redirect()->route('product.index');
    }

    /**
     * Remove the specified resource from storage.
     *
     * @param  int  $id
     * @return \Illuminate\Http\Response
     */
    public function destroy($id)
    {
        $product=Product::findOrFail($id);
        $status=$product->delete();
        
        if($status){
            request()->session()->flash('success','Product successfully deleted');
        }
        else{
            request()->session()->flash('error','Error while deleting product');
        }
        return redirect()->route('product.index');
    }
}
