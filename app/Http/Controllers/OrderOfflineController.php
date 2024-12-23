<?php

// app/Http/Controllers/OrderOfflineController.php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use App\Models\Order;
use App\Models\OrderItem;
use Illuminate\Support\Str;
use PDF;   
use App\Models\Product;

class OrderOfflineController extends Controller
{
    // Menampilkan form untuk membuat order baru (Create)
    // use Illuminate\Support\Str; // Import Str

    public function create()
    {
        $products = Product::all(); // Ambil semua produk
    
        // Generate order number otomatis
        $orderNumber = strtoupper(uniqid('ORD-', true)); // Contoh format nomor pesanan: ORD-XXXXXXXX
    
        return view('backend.orders.create', compact('products', 'orderNumber'));
    }
    

    // Menyimpan data order baru ke database (Store)
    public function store(Request $request)
    {
        // Validasi input data
        $validatedData = $request->validate([
            'order_number' => 'required|string|max:255',
            'product_id' => 'required|array', // Pastikan product_id adalah array
            'product_id.*' => 'integer|exists:products,id', // Validasi ID produk
            'quantity' => 'required|array', // Quantity harus berupa array
            'quantity.*' => 'nullable|integer|min:1', // Quantity minimal 1
        ]);
        
        // Validasi conditional: Quantity harus ada jika produk dipilih
        foreach ($request->product_id as $productId) {
            if (empty($request->quantity[$productId]) || $request->quantity[$productId] < 1) {
                return redirect()->back()
                    ->withErrors(['quantity' => 'Quantity wajib diisi untuk produk yang dipilih.'])
                    ->withInput();
            }
        }
        
    
        // Simpan data order ke database
        $order = Order::create([
            'order_number' => $validatedData['order_number'],  // Menggunakan order_number yang terisi otomatis
            'sub_total' => $request->sub_total,
            'total_amount' => $request->total_amount,
            // 'quantity' => $request->quantity ? array_sum($request->quantity) : 0,
            'payment_method' => $request->payment_method,
            'payment_status' => $request->payment_status,
            'status' => $request->status,
            'first_name' => $request->first_name,
            'last_name' => $request->last_name,
            'email' => $request->email,
            'phone' => $request->phone,
            'address' => $request->address,
        ]);
    
        // Simpan produk yang dipilih ke tabel order_items
        foreach ($validatedData['product_id'] as $productId) {
            $product = Product::find($productId); // Ambil detail produk
    
            // Pastikan stok cukup sebelum mengurangi
            if ($product->stock < $request->quantity[$productId]) {
                return redirect()->back()->withErrors(['quantity' => 'Stok produk tidak cukup untuk produk ' . $product->name]);
            }
    
            // Kurangi stok produk sesuai dengan quantity yang dipesan
            $product->stock -= $request->quantity[$productId];
            $product->save();
    
            // Simpan order item
            OrderItem::create([
                'order_id' => $order->id,
                'product_id' => $product->id,
                'quantity' => $request->quantity[$productId], // Ambil quantity sesuai produk
                'unit_price' => $product->price,
                'subtotal' => $product->price * $request->quantity[$productId],
            ]);
        }
    
        // Redirect ke halaman order index atau beri feedback sukses
        return redirect()->route('order.index')->with('success', 'Order successfully created!');
    }
    
    
    
    
    public function pdf(Request $request)
{
    set_time_limit(120); // Pastikan ada cukup waktu untuk proses render PDF
    
    // Ambil data order berdasarkan ID yang diberikan
    $order = Order::with(['orderItems.product', 'shipping'])->findOrFail($request->id);

    // Hitung biaya pengiriman (shippingCost)
    $shippingCost = $order->shipping ? $order->shipping->price : 0;

    // Hitung totalAmount (subtotal + shippingCost)
    $totalAmount = $order->sub_total + $shippingCost;

    // Nama file PDF
    $file_name = $order->order_number . '-' . $order->first_name . '.pdf';

    // Load view untuk PDF
    $pdf = PDF::loadView('backend.orders.pdf', compact('order', 'shippingCost', 'totalAmount'));

    // Download PDF
    return $pdf->download($file_name);
}
    

    // Menampilkan daftar semua order (Index)
    public function index()
    {
        $orders = Order::all(); // Ambil semua data order
        return view('order.index', compact('orders'));
    }

    // Menampilkan detail order (Show)
    public function show($id)
    {
        $order = Order::findOrFail($id);
        return view('order.show', compact('order'));
    }

    // Menampilkan form untuk mengedit order (Edit)
    public function edit($id)
    {
        $order = Order::findOrFail($id);
        return view('order.edit', compact('order'));
    }

    // Menyimpan perubahan pada order (Update)
    public function update(Request $request, $id)
    {
        // Validasi input data
        $validatedData = $request->validate([
            'order_number' => 'required|string|max:255',
            // 'product_id' => 'nullable|integer',
            'sub_total' => 'required|numeric',
            'total_amount' => 'required|numeric',
            'quantity' => 'required|integer',
            'payment_method' => 'required|in:bayarditoko,transfer_bank',
            'payment_status' => 'required|in:sudah dibayar,belum dibayar',
            'status' => 'required|in:pending,process,finished,cancel',
            'first_name' => 'required|string|max:191',
            'last_name' => 'required|string|max:191',
            'email' => 'required|email|max:191',
            'phone' => 'required|string|max:191',
            'address' => 'required|string|max:191',
            'product_id' => 'required|exists:products,id',
        ]);

        // Cari order berdasarkan ID dan update
        $order = Order::findOrFail($id);
        $order->update($validatedData);

        // Redirect ke halaman index
        return redirect()->route('order.index')->with('success', 'Order successfully updated!');
    }

    // Menghapus order (Destroy)
    public function destroy($id)
    {
        $order = Order::findOrFail($id);
        $order->delete();

        return redirect()->route('order.index')->with('success', 'Order successfully deleted!');
    }
}