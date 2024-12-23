@extends('backend.layouts.master')

@section('title', 'Discounted Products')

@section('main-content')
<div class="card"> <!-- Ubah div utama menjadi class "card" -->
    <div class="card-header"> <!-- Tambahkan card-header -->
        <h4>Discounted Products</h4>
    </div>
    <div class="card-body"> <!-- Ubah container utama menjadi card-body -->
        <table class="table table-bordered">
            <thead>
                <tr>
                    <th>ID</th>
                    <th>Title</th>
                    <th>Slug</th>
                    <th>Original Price</th>
                    <th>Discount Percentage</th> <!-- Tambahkan kolom untuk persen diskon -->
                    <th>Discount Value</th>
                    <th>Discounted Price</th>
                    <th>Stock</th>
                    <th>Created At</th>
                </tr>
            </thead>
            <tbody>
                @foreach ($discountedProducts as $product)
                    <tr>
                        <td>{{ $product->product_id }}</td>
                        <td>{{ $product->product_title }}</td>
                        <td>{{ $product->product_slug }}</td>
                        <td>Rp {{ number_format($product->original_price, 2, ',', '.') }}</td>
                        <td>{{ $product->discount_percentage }}%</td> <!-- Tambahkan kolom untuk persen diskon -->
                        <td>Rp {{ number_format($product->discount_amount, 2, ',', '.') }}</td>
                        <td>Rp {{ number_format($product->discounted_price, 2, ',', '.') }}</td>
                        <td>{{ $product->product_stock }}</td>
                        <td>{{ $product->product_created_at }}</td>
                    </tr>
                @endforeach
            </tbody>
        </table>
        <!-- Pagination -->
        <div class="mt-4">
            {{ $discountedProducts->links() }}
        </div>
    </div>
</div>
@endsection
