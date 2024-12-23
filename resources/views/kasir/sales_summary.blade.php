@extends('backend.layouts.master')
@section('title', 'Sales Summary')

@section('main-content')
<div class="container-fluid">
    <h3 class="mb-4">Sales Summary</h3>

    <!-- Tabel Menampilkan Sales Summary -->
    <div class="card shadow mb-4">
        <div class="card-header py-3">
            <h6 class="m-0 font-weight-bold text-white">Top 10 Best-Selling Products</h6>
        </div>
        <div class="card-body">
            <div class="table-responsive">
                <table class="table table-bordered">
                    <thead>
                        <tr>
                            <th>Product ID</th>
                            <th>Product Title</th>
                            <th>Total Sold</th>
                            <th>Total Sales Value</th>
                        </tr>
                    </thead>
                    <tbody>
                        @foreach ($salesSummary as $item)
                        <tr>
                            <td>{{ $item->product_id }}</td>
                            <td>{{ $item->product_title }}</td>
                            <td>{{ $item->total_sold }}</td>
                            <td>Rp {{ number_format($item->total_sales_value, 2, ',', '.') }}</td>
                        </tr>
                        @endforeach
                    </tbody>
                </table>
            </div>
        </div>
    </div>
</div>
@endsection
