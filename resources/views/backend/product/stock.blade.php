@extends('backend.layouts.master')

@section('title', 'Product Stock by Category')

@section('main-content')
<div class="card">
    <div class="card-header">
        <h4>Check Product Stock</h4>
    </div>
    <div class="card-body">
        <!-- Form Input Kategori -->
        <form action="{{ route('product.stock') }}" method="POST">
            @csrf
            <div class="form-group">
                <label for="category_id">Pilih Kategori</label>
                <select name="category_id" id="category_id" class="form-control" required>
                    <option value="" disabled selected>-- Pilih Kategori --</option>
                    @foreach ($categories as $category)
                        <option value="{{ $category->id }}" {{ isset($categoryId) && $categoryId == $category->id ? 'selected' : '' }}>
                            {{ $category->title }}
                        </option>
                    @endforeach
                </select>
                
                
            </div>
            
            <button type="submit" class="btn btn-primary">Check Stock</button>
        </form>

        @if(isset($products))
        <!-- Tabel Hasil Stok Produk -->
        <h5 class="mt-4">Stock Results for Category ID: {{ $categoryId }}</h5>
        <table class="table table-bordered">
            <thead>
                <tr>
                    <th>Product ID</th>
                    <th>Product Name</th>
                    <th>Stock</th>
                </tr>
            </thead>
            <tbody>
                @foreach($products as $product)
                <tr>
                    <td>{{ $product->product_id }}</td>
                    <td>{{ $product->product_name }}</td>
                    <td>{{ $product->stock }}</td>
                </tr>
                @endforeach
            </tbody>
        </table>
        @endif
    </div>
</div>
@endsection
