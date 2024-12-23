@extends('backend.layouts.master')

@section('title', 'Payment Status')

@section('main-content')
<div class="card">
    <h5 class="card-header" style="background-color: #776B5D; color: #FFFFFF;">
        Payment Status
    </h5>
    
    <div class="card-body">
        @if($payments->isNotEmpty())
        <table class="table table-striped table-hover">
            <thead>
                <tr>
                    <th>Order ID</th>
                    <th>Order Number</th>
                    <th>User ID</th>
                    <th>Payment Method</th>
                    <th>Payment Status</th>
                    <th>Total Amount</th>
                    <th>Payment Proof</th>
                    <th>Order Date</th>
                    <th>Last Updated</th>
                </tr>
            </thead>
            <tbody>
                @foreach ($payments as $payment)
                <tr>
                    <td>{{ $payment->order_id }}</td>
                    <td>{{ $payment->order_number }}</td>
                    <td>{{ $payment->user_id }}</td>
                    <td>{{ $payment->payment_method }}</td>
                    <td>
                        @if ($payment->payment_status == 'sudah dibayar')
                            <span class="badge badge-success">Sudah Dibayar</span>
                        @else
                            <span class="badge badge-danger">Belum Dibayar</span>
                        @endif
                    </td>
                    <td>Rp{{ number_format($payment->total_amount, 2) }}</td>
                    <td>
                        @if ($payment->payment_proof)
                            <a href="{{ asset('storage/' . $payment->payment_proof) }}" target="_blank">View Proof</a>
                        @else
                            No Proof
                        @endif
                    </td>
                    <td>{{ $payment->order_date }}</td>
                    <td>{{ $payment->last_updated }}</td>
                </tr>
                @endforeach
            </tbody>
        </table>
        @else
        <p class="text-center">No payment records found.</p>
        @endif
    </div>
</div>
@endsection

@push('styles')
<style>
    .card-header {
        font-size: 1.25rem;
        font-weight: bold;
        background: #ECECEC;
        border-bottom: 2px solid #ddd;
    }

    table.table {
        margin-top: 20px;
    }

    .badge-success {
        background-color: #28a745;
        color: white;
        padding: 5px 10px;
        border-radius: 5px;
    }

    .badge-danger {
        background-color: #dc3545;
        color: white;
        padding: 5px 10px;
        border-radius: 5px;
    }
</style>
@endpush
