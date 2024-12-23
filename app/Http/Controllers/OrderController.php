<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use App\Models\Cart;
use App\Models\VOrdersPickup;
use App\Models\Order;
use App\Models\OrderItem;
use App\Models\Shipping;
use App\Models\ViewSalesSummary;
use App\User;
use PDF;
use Notification;
use Helper;
use Illuminate\Support\Str;
use App\Notifications\StatusNotification;

class OrderController extends Controller
{
    /**
     * Display a listing of the resource.
     *
     * @return \Illuminate\Http\Response
     */
    public function index()
    {
        $orders=Order::orderBy('id','DESC')->paginate(10);
        return view('backend.order.index')->with('orders',$orders);
    }

    /**
     * Show the form for creating a new resource.
     *
     * @return \Illuminate\Http\Response
     */
    public function create()
    {
        // Generate Order Number secara otomatis
        $orderNumber = 'ORD-' . strtoupper(Str::random(10));
    
        // Kirim ke view
        return view('backend.orders.create', compact('orderNumber'));
    }
    

    /**
     * Store a newly created resource in storage.
     *
     * @param  \Illuminate\Http\Request  $request
     * @return \Illuminate\Http\Response
     */
    public function store(Request $request)
    {
        // Validasi umum yang berlaku untuk semua metode pembayaran
        $this->validate($request, [
            'first_name' => 'string|required',
            'last_name' => 'string|required',
            'address' => 'string|required',
            'phone' => 'numeric|required',
            'email' => 'string|required',
        ]);
    
        // Validasi spesifik berdasarkan metode pembayaran
        if ($request->payment_method === 'transfer_bank') {
            $this->validate($request, [
                'shipping_id' => 'required|exists:shippings,id',
            ]);
        } elseif ($request->payment_method === 'bayarditoko') {
            $this->validate($request, [
                'pickup_date' => 'required|date|after_or_equal:today',
            ]);
        }
    
        // Pastikan Cart tidak kosong
        $cartItems = Cart::where('user_id', auth()->user()->id)->where('order_id', null)->get();
        if ($cartItems->isEmpty()) {
            return back()->with('error', 'Cart is empty!');
        }
    
        // Hitung subtotal dan total
        $subTotal = Helper::totalCartPrice();
        $shippingCost = 0;
    
        if ($request->payment_method === 'transfer_bank') {
            $shippingCost = Shipping::where('id', $request->shipping_id)->value('price') ?? 0;
        }
    
        $totalAmount = $subTotal + $shippingCost;
    
        // Simpan data pesanan ke tabel orders
        $order = new Order();
        $order->fill([
            'user_id' => auth()->user()->id,
            'order_number' => 'ORD-' . strtoupper(Str::random(10)),
            'sub_total' => $subTotal,
            'total_amount' => $totalAmount,
            'first_name' => $request->first_name,
            'last_name' => $request->last_name,
            'address' => $request->address,
            'phone' => $request->phone,
            'email' => $request->email,
            'status' => 'pending',
            'payment_method' => $request->payment_method,
            'payment_status' => 'belum dibayar',
        ]);
    
        // Tentukan apakah pesanan memerlukan shipping_id atau pickup_date
        if ($request->payment_method === 'transfer_bank') {
            $order->shipping_id = $request->shipping_id;
        } elseif ($request->payment_method === 'bayarditoko') {
            $order->pickup_date = $request->pickup_date;
        }
    
        $order->save();
    
        // Simpan setiap item dari Cart ke tabel order_items
        foreach ($cartItems as $cartItem) {
            $orderItem = new OrderItem();
            $orderItem->fill([
                'order_id' => $order->id,
                'product_id' => $cartItem->product_id,
                'quantity' => $cartItem->quantity,
                'unit_price' => $cartItem->price,
                'subtotal' => $cartItem->quantity * $cartItem->price,
            ]);
            $orderItem->save();
        }
    
        // Kurangi stok produk
        foreach ($cartItems as $cartItem) {
            $product = $cartItem->product;
            if ($product->stock >= $cartItem->quantity) {
                $product->stock -= $cartItem->quantity;
                $product->save();
            } else {
                return back()->with('error', 'Not enough stock for ' . $product->name);
            }
        }
    
        // Hapus item dari Cart setelah checkout berhasil
        Cart::where('user_id', auth()->user()->id)->where('order_id', null)->delete();
    
        return redirect()->route('home')->with('success', 'Your order has been placed successfully.');
    }



    public function pickupOrders()
    {
        // Ambil data dari view v_orders_pickup
        $orders = VOrdersPickup::orderBy('pickup_date', 'asc')->get();

        // Kirim data ke pickup.blade.php
        return view('backend.orders.pickup', compact('orders'));
    }
    

    public function handleBayarDiToko(Request $request, Order $order)
{
    $this->validate($request, [
        'pickup_date' => 'required|date|after_or_equal:today',
    ]);

    $order->pickup_date = $request->pickup_date;
    $order->payment_status = 'pending';
    $order->save();
}

    
    
    

    public function showBankTransfer($id)
    {
        $order = Order::findOrFail($id); // Pastikan model Order sudah diimport
        return view('frontend.pages.bank-transfer', compact('order'));
    }

    public function uploadPaymentProof(Request $request)
    {
        $request->validate([
            'payment_proof' => 'required|image|mimes:jpeg,png,jpg,gif|max:2048', // Validasi file
        ]);
    
        if ($request->hasFile('payment_proof')) {
            $file = $request->file('payment_proof');
            $fileName = time() . '_' . $file->getClientOriginalName();
            $file->storeAs('public/payment_proofs', $fileName);
    
            $order = Order::find($request->order_id);
            if ($order) {
                $order->payment_proof = 'payment_proofs/' . $fileName;
                $order->save();
            }
    
            return back()->with('success', 'Bukti pembayaran berhasil diunggah.');
        }
    
        return back()->with('error', 'Gagal mengunggah bukti pembayaran.');
    }


    public function totalPendapatan(Request $request)
    {
        // Default tanggal jika tidak diinput
        $start_date = $request->input('start_date', date('Y-m-01'));
        $end_date = $request->input('end_date', date('Y-m-d'));
    
        // Panggil stored function untuk menghitung total pendapatan
        $totalIncome = \DB::selectOne("SELECT total_income_in_period(?, ?) AS total_income", [$start_date, $end_date]);
        $income = $totalIncome->total_income ?? 0;
    
        // Filter orders berdasarkan kriteria
        $orders = Order::where('status', 'finished')
                       ->where('payment_status', 'sudah dibayar')
                       ->whereBetween('created_at', [$start_date, $end_date])
                       ->orderBy('id', 'DESC')
                       ->paginate(10);
    
        // Return data ke view
        return view('kasir.total_pendapatan', compact('orders', 'income', 'start_date', 'end_date'));
    }
    



public function salesSummary()
{
    // Ambil data dari model ViewSalesSummary
    $salesSummary = ViewSalesSummary::orderBy('total_sold', 'DESC')->get();

    // Kirim data ke view
    return view('kasir.sales_summary', compact('salesSummary'));
}



    /**
     * Display the specified resource.
     *
     * @param  int  $id
     * @return \Illuminate\Http\Response
     */
    public function show($id)
    {
        $order = Order::with('orderItems.product')->find($id);
    
        if (!$order) {
            return redirect()->back()->with('error', 'Order not found');
        }
    
        // Hitung shipping cost
        $shippingCost = $order->shipping ? $order->shipping->price : 0;
    
        // Hitung total amount (subtotal + shipping)
        $totalAmount = $order->sub_total + $shippingCost;
    
        return view('user.order.show', compact('order', 'shippingCost', 'totalAmount'));
    }
    
    
    

    /**
     * Show the form for editing the specified resource.
     *
     * @param  int  $id
     * @return \Illuminate\Http\Response
     */
    public function edit($id)
    {
        $order=Order::find($id);
        return view('backend.order.edit')->with('order',$order);
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
        $order = Order::find($id);
    
        // Validasi input
        $this->validate($request, [
            'status' => 'required|in:pending,process,finished,cancel'
        ]);
    
        $data = $request->all();
    
        // Jika status diubah menjadi 'finished', stok dikurangi
        if ($request->status == 'finished') {
            foreach ($order->orderItems as $item) {
                $product = $item->product;
                $product->stock -= $item->quantity;
                $product->save();
            }
        }
    
        // Jika status diubah menjadi 'cancel', panggil stored procedure untuk mengembalikan stok
        if ($request->status == 'cancel') {
            \DB::statement('CALL restore_stock_on_cancel(?)', [$order->id]);
        }
    
        // Update status order
        $status = $order->fill($data)->save();
    
        if ($status) {
            request()->session()->flash('success', 'Successfully updated order');
        } else {
            request()->session()->flash('error', 'Error while updating order');
        }
    
        return redirect()->route('order.index');
    }
    

    /**
     * Remove the specified resource from storage.
     *
     * @param  int  $id
     * @return \Illuminate\Http\Response
     */
    public function destroy($id)
    {
        $order=Order::find($id);
        if($order){
            $status=$order->delete();
            if($status){
                request()->session()->flash('success','Order Successfully deleted');
            }
            else{
                request()->session()->flash('error','Order can not deleted');
            }
            return redirect()->route('order.index');
        }
        else{
            request()->session()->flash('error','Order can not found');
            return redirect()->back();
        }
    }

    public function orderTrack(){
        return view('frontend.pages.order-track');
    }

    public function productTrackOrder(Request $request){
        // return $request->all();
        $order=Order::where('user_id',auth()->user()->id)->where('order_number',$request->order_number)->first();
        if($order){
            if($order->status=="pending"){
            request()->session()->flash('success','Your order has been placed. please wait.');
            return redirect()->route('home');

            }
            elseif($order->status=="process"){
                request()->session()->flash('success','Your order is under processing please wait.');
                return redirect()->route('home');
    
            }
            elseif($order->status=="finished"){
                request()->session()->flash('success','Your order is successfully finished.');
                return redirect()->route('home');
    
            }
            else{
                request()->session()->flash('error','Your order canceled. please try again');
                return redirect()->route('home');
    
            }
        }
        else{
            request()->session()->flash('error','Invalid order numer please try again');
            return back();
        }
    }

    // PDF generate
    public function pdf(Request $request) {
        set_time_limit(120);
        $order = Order::getAllOrder($request->id);
    
        // Pastikan data shipping_cost diambil dengan benar
        $shippingCost = $order->shipping ? $order->shipping->price : 0;
    
        // Periksa total_amount
        $totalAmount = $order->sub_total + $shippingCost;
    
        // Debugging jika diperlukan
        // dd($order->sub_total, $shippingCost, $totalAmount);
    
        $file_name = $order->order_number . '-' . $order->first_name . '.pdf';
        $pdf = PDF::loadview('backend.order.pdf', compact('order', 'shippingCost', 'totalAmount'));
        return $pdf->download($file_name);
    }
    
    
    
    // Income chart
    public function incomeChart(Request $request)
    {
        // Mendapatkan tahun yang sedang dipilih, default adalah tahun sekarang
        $year = $request->input('year', \Carbon\Carbon::now()->year);
    
        // Mengambil semua orders dengan status finished untuk tahun yang dipilih
        $orders = Order::whereYear('created_at', $year)
            ->where('status', 'finished')
            ->get()
            ->groupBy(function ($order) {
                // Kelompokkan berdasarkan bulan dalam format angka (01, 02, ...)
                return \Carbon\Carbon::parse($order->created_at)->format('m');
            });
    
        $result = [];
    
        // Menghitung total pendapatan per bulan
        foreach ($orders as $month => $orderCollection) {
            $totalAmount = $orderCollection->sum(function ($order) {
                // Pastikan kolom total_amount berisi total pendapatan dari order
                return $order->total_amount;
            });
    
            $monthIndex = intval($month); // Konversi bulan ke integer
            $result[$monthIndex] = $totalAmount;
        }
    
        // Format data untuk setiap bulan (Jan - Dec), isi dengan 0 jika tidak ada data
        $data = [];
        for ($i = 1; $i <= 12; $i++) {
            $monthName = date('F', mktime(0, 0, 0, $i, 1)); // Nama bulan
            $data[$monthName] = isset($result[$i]) ? number_format((float) $result[$i], 2, '.', '') : 0.0;
        }
    
        return response()->json($data); // Mengembalikan data dalam format JSON
    }
    





}