<?php

namespace App\Http\Controllers;

use App\Models\Customer;
use Illuminate\Http\Request;

class CustomerController extends Controller
{
    // Menampilkan daftar semua pelanggan
    public function index()
    {
        $customers = Customer::all(); // Ambil semua data dari tabel customers
        return view('customers.index', compact('customers')); // Kirim data ke view
    }

    // Menampilkan form untuk menambah customer
    public function create()
    {
        return view('customers.create'); // Menampilkan halaman form untuk create
    }

    // Menyimpan data customer ke dalam database
    public function store(Request $request)
    {
        // Validasi input dari user
        $request->validate([
            'customer_id' => 'required|unique:customers|max:255',
            'name' => 'required|string|max:255',
            'phone' => 'required|string|max:20',
            'email' => 'required|email|max:255',
            'address' => 'required|string|max:255',
        ]);

        // Menyimpan data customer
        Customer::create([
            'customer_id' => $request->customer_id,
            'name' => $request->name,
            'phone' => $request->phone,
            'email' => $request->email,
            'address' => $request->address,
        ]);

        return redirect()->route('customers.index')->with('success', 'Customer created successfully.');
    }

    // Menampilkan form untuk mengedit customer berdasarkan customer_id
    public function edit($customer_id)
    {
        $customer = Customer::findOrFail($customer_id); // Cari customer berdasarkan customer_id
        return view('customers.edit', compact('customer')); // Kirim data customer ke view edit
    }

    // Mengupdate data customer berdasarkan customer_id
    public function update(Request $request, $customer_id)
    {
        // Validasi input
        $request->validate([
            'name' => 'required|string|max:255',
            'phone' => 'required|string|max:20',
            'email' => 'required|email|max:255',
            'address' => 'required|string|max:255',
        ]);

        // Cari customer berdasarkan customer_id dan update
        $customer = Customer::findOrFail($customer_id);
        $customer->update([
            'name' => $request->name,
            'phone' => $request->phone,
            'email' => $request->email,
            'address' => $request->address,
        ]);

        return redirect()->route('customers.index')->with('success', 'Customer updated successfully.');
    }

    // Menghapus customer berdasarkan customer_id
    public function destroy($customer_id)
    {
        $customer = Customer::findOrFail($customer_id); // Cari customer berdasarkan customer_id
        $customer->delete(); // Hapus customer

        return redirect()->route('customers.index')->with('success', 'Customer deleted successfully.');
    }
}
