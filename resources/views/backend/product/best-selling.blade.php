@extends('backend.layouts.master')

@section('title', 'Best Selling Products')

@section('main-content')
<div class="card">
    <div class="card-header">
        <h4>Best Selling Products</h4>
    </div>
    <div class="card-body">
        <table class="table table-bordered">
            <thead>
                <tr>
                    <th>Product ID</th>
                    <th>Product Name</th>
                    <th>Total Sold</th>
                </tr>
            </thead>
            <tbody>
                @foreach ($bestSellingProducts as $product)
                <tr>
                    <td>{{ $product->product_id }}</td>
                    <td>{{ $product->product_name }}</td>
                    <td>{{ $product->total_sold }}</td>
                </tr>
                @endforeach
            </tbody>
        </table>
    </div>
</div>
@endsection
