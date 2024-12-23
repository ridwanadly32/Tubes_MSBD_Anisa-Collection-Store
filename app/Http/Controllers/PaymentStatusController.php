<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class PaymentStatusController extends Controller
{
    public function index()
    {
        // Mengambil data dari view "payment_status_view"
        $payments = DB::table('payment_status_view')->get();

        // Mengirim data ke blade view
        return view('backend.payment-status.index', compact('payments'));
    }
}
