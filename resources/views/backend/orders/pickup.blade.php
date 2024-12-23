@extends('backend.layouts.master') {{-- Menggunakan layout yang sama --}}

@section('title', 'Pickup Orders')

@section('main-content')
<div class="card">
    <h5 class="card-header">Pickup Orders</h5>
    <div class="card-body">
        <table class="table table-striped table-hover">
            <thead>
                <tr>
                    <th>ID</th>
                    <th>Order Number</th>
                    <th>Pickup Date</th>
                    <th>First Name</th>
                    <th>Last Name</th>
                    <th>Phone</th>
                    <th>Total Amount</th>
                    <th>Status</th>
                </tr>
            </thead>
            <tbody>
                @foreach ($orders as $order)
                    <tr>
                        <td>{{ $order->id }}</td>
                        <td>{{ $order->order_number }}</td>
                        <td>{{ $order->pickup_date }}</td>
                        <td>{{ $order->first_name }}</td>
                        <td>{{ $order->last_name }}</td>
                        <td>{{ $order->phone }}</td>
                        <td>Rp {{ number_format($order->total_amount, 2) }}</td>
                        <td>
                            @if ($order->status == 'pending')
                                <span class="badge badge-primary">{{ $order->status }}</span>
                            @elseif ($order->status == 'process')
                                <span class="badge badge-warning">{{ $order->status }}</span>
                            @elseif ($order->status == 'finished')
                                <span class="badge badge-success">{{ $order->status }}</span>
                            @else
                                <span class="badge badge-danger">{{ $order->status }}</span>
                            @endif
                        </td>
                    </tr>
                @endforeach
            </tbody>
        </table>
    </div>
</div>
@endsection

@push('styles')
<style>
    .table th, .table td {
        text-align: center;
    }
</style>
@endpush
