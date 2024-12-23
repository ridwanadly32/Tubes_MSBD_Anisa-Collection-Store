<?php

namespace App\Http\Controllers;

use App\Models\Transaction;  // Pastikan model Transaction sudah ada
use Illuminate\Http\Request;

class TransactionController extends Controller
{
    /**
     * Menampilkan form untuk menambah transaksi baru.
     *
     * @return \Illuminate\View\View
     */
    public function create()
    {
        // Menampilkan view create
        return view('backend.transaction.create');
    }

    /**
     * Menyimpan transaksi yang baru ditambahkan.
     *
     * @param \Illuminate\Http\Request $request
     * @return \Illuminate\Http\Response
     */
    public function store(Request $request)
    {
        // Validasi input dari form
        $request->validate([
            'transaction_id' => 'required|string|max:255|unique:transactions,transaction_id',
            'customer_id' => 'required|integer|exists:customers,customer_id',
            'transaction_date' => 'required|date',
            'total_amount' => 'required|numeric|min:0',
            'status' => 'required|in:Pending,Completed,Cancelled',
        ]);
    
        // Menyimpan transaksi baru ke dalam tabel transactions
        $transaction = Transaction::create([
            'transaction_id' => $request->input('transaction_id'),
            'customer_id' => $request->input('customer_id'),
            'transaction_date' => $request->input('transaction_date'),
            'total_amount' => $request->input('total_amount'),
            'status' => $request->input('status'),
        ]);
    
        // Menambahkan pesan sukses atau error
        if ($transaction) {
            session()->flash('success', 'Transaksi berhasil ditambahkan!');
        } else {
            session()->flash('error', 'Terjadi kesalahan saat menambahkan transaksi.');
        }
    
        // Mengambil semua transaksi untuk ditampilkan di halaman
        $transactions = Transaction::all();
    
        // Mengarahkan kembali ke halaman daftar transaksi dan mengirimkan data transaksi
        return redirect()->route('transaction.index')->with('transactions', Transaction::all());


    }
    
    
    
    
    

    /**
     * Menampilkan daftar transaksi.
     *
     * @return \Illuminate\View\View
     */
    public function index()
    {
        // Mengambil semua transaksi dari database
        $transactions = Transaction::all();
    
        // Kirim data transaksi ke view untuk ditampilkan
        return view('backend.transaction.show', compact('transactions'));
    }
    

    public function show($transaction_id)
    {
        // Cek jika transaksi ditemukan berdasarkan transaction_id
        $transaction = Transaction::where('transaction_id', $transaction_id)->first();
        
        if (!$transaction) {
            return redirect()->route('transaction.index')->with('error', 'Transaction not found!');
        }
    
        // Ambil semua transaksi untuk ditampilkan juga
        $transactions = Transaction::all();
    
        // Kirim variabel ke view
        return view('backend.transaction.show', compact('transaction', 'transactions'));
    }
    
    
    
    

    
    
    
    
public function up()
{
    Schema::table('transactions', function (Blueprint $table) {
        // Menambahkan kolom id auto-increment
        $table->increments('id')->first();  // menambahkan kolom id pertama
    });
}

public function down()
{
    Schema::table('transactions', function (Blueprint $table) {
        // Menghapus kolom id
        $table->dropColumn('id');
    });
}



}