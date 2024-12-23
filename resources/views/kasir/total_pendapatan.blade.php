@extends('backend.layouts.master')
@section('title', 'Total Pendapatan')

@section('main-content')
<div class="container-fluid">
    @include('backend.layouts.notification')

    <!-- Form Input Rentang Tanggal -->
    <div class="card shadow mb-4">
        <div class="card-header py-3">
            <h6 class="m-0 font-weight-bold text-primary">Filter Pendapatan Berdasarkan Tanggal</h6>
        </div>
        <div class="card-body">
            <form method="GET" action="{{ route('kasir.total_pendapatan') }}">
                <div class="row">
                    <div class="col-md-5">
                        <label for="start_date">Tanggal Mulai</label>
                        <input type="date" name="start_date" class="form-control" value="{{ old('start_date', $start_date) }}">
                    </div>
                    <div class="col-md-5">
                        <label for="end_date">Tanggal Selesai</label>
                        <input type="date" name="end_date" class="form-control" value="{{ old('end_date', $end_date) }}">
                    </div>
                    <div class="col-md-2 d-flex align-items-end">
                        <button type="submit" class="btn btn-primary btn-block">Filter</button>
                    </div>
                </div>
            </form>
        </div>
    </div>

    <!-- Total Pendapatan -->
    <div class="card shadow mb-4">
        <div class="card-header py-3">
            <h6 class="m-0 font-weight-bold">Total Pendapatan</h6>
        </div>
        <div class="card-body">
            <h4 class="text-success font-weight-bold">Rp {{ number_format($income, 2, ',', '.') }}</h4>
        </div>
    </div>

    <!-- Daftar Pesanan -->
    <div class="card shadow mb-4">
        <div class="card-header py-3">
            <h6 class="m-0 font-weight-bold text-primary">Daftar Pesanan (Finished & Sudah Dibayar)</h6>
        </div>
        <div class="card-body">
            <div class="table-responsive">
                <table class="table table-bordered table-striped">
                    <thead class="thead-dark">
                        <tr>
                            <th>ID</th>
                            <th>Order Number</th>
                            <th>Status</th>
                            <th>Total Amount</th>
                            <th>Tanggal</th>
                        </tr>
                    </thead>
                    <tbody>
                        @forelse ($orders as $order)
                            <tr>
                                <td>{{ $order->id }}</td>
                                <td>{{ $order->order_number }}</td>
                                <td><span class="badge badge-success">{{ ucfirst($order->status) }}</span></td>
                                <td>Rp {{ number_format($order->total_amount, 2, ',', '.') }}</td>
                                <td>{{ $order->created_at->format('Y-m-d H:i:s') }}</td>
                            </tr>
                        @empty
                            <tr>
                                <td colspan="5" class="text-center text-danger">Tidak ada data pesanan untuk rentang tanggal ini.</td>
                            </tr>
                        @endforelse
                    </tbody>
                </table>
            </div>

            <!-- Pagination -->
            <div class="mt-3">
                {{ $orders->appends(request()->input())->links() }}
            </div>
        </div>
    </div>
</div>
@endsection
