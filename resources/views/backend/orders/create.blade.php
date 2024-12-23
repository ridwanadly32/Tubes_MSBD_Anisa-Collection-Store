@extends('backend.layouts.master')

@section('main-content')

<div class="card">
  <h5 class="card-header">Add Order</h5>
  <div class="card-body">
    <form method="post" action="{{ route('orders.store') }}" enctype="multipart/form-data">
      @csrf
<!-- Order Number -->
<div class="form-group">
  <label for="order_number" class="col-form-label">Order Number <span class="text-danger">*</span></label>
  <input id="order_number" type="text" name="order_number" value="{{ old('order_number', $orderNumber) }}" class="form-control" readonly>
</div>


      <!-- Produk -->
      <div class="form-group">
        <label for="product_id" class="col-form-label">Produk <span class="text-danger">*</span></label>
        <div>
          @foreach($products as $product)
          <div class="d-flex align-items-center mb-2">
            <!-- Checkbox untuk memilih produk -->
            <input 
    type="checkbox" 
    id="product_{{ $product->id }}" 
    name="product_id[]" 
    value="{{ $product->id }}" 
    {{ (is_array(old('product_id')) && in_array($product->id, old('product_id'))) ? 'checked' : '' }}>


            <!-- Label Produk -->
            <label for="product_{{ $product->id }}" class="ml-2" style="flex: 1; margin-left: 10px;">
              {{ $product->title }} - Rp{{ number_format($product->price, 0, ',', '.') }}
            </label>

            <!-- Input untuk quantity -->
            <input 
              type="number" 
              name="quantity[{{ $product->id }}]" 
              placeholder="Qty" 
              value="{{ old('quantity.' . $product->id) }}" 
              class="form-control" 
              style="width: 100px; margin-left: 20px; text-align: center;" 
              min="1">
          </div>
          @endforeach
        </div>
        @error('product_id') <span class="text-danger">{{ $message }}</span> @enderror
        @error('quantity') <span class="text-danger">{{ $message }}</span> @enderror
      </div>

      <!-- Sub Total -->
      <div class="form-group">
        <label for="sub_total" class="col-form-label">Sub Total <span class="text-danger">*</span></label>
        <input id="sub_total" type="number" step="0.01" name="sub_total" placeholder="Enter sub total" value="{{ old('sub_total') }}" class="form-control">
        @error('sub_total') <span class="text-danger">{{ $message }}</span> @enderror
      </div>

      <!-- Total Amount -->
      <div class="form-group">
        <label for="total_amount" class="col-form-label">Total Amount <span class="text-danger">*</span></label>
        <input id="total_amount" type="number" step="0.01" name="total_amount" placeholder="Enter total amount" value="{{ old('total_amount') }}" class="form-control">
        @error('total_amount') <span class="text-danger">{{ $message }}</span> @enderror
      </div>

      <!-- Payment Method -->
      <div class="form-group">
        <label for="payment_method" class="col-form-label">Payment Method <span class="text-danger">*</span></label>
        <select name="payment_method" class="form-control">
          <option value="bayarditoko" {{ old('payment_method') == 'bayarditoko' ? 'selected' : '' }}>Bayar di Toko</option>
          <option value="transfer_bank" {{ old('payment_method') == 'transfer_bank' ? 'selected' : '' }}>Transfer Bank</option>
        </select>
        @error('payment_method') <span class="text-danger">{{ $message }}</span> @enderror
      </div>

      <!-- Payment Status -->
      <div class="form-group">
        <label for="payment_status" class="col-form-label">Payment Status <span class="text-danger">*</span></label>
        <select name="payment_status" class="form-control">
          <option value="sudah dibayar" {{ old('payment_status') == 'sudah dibayar' ? 'selected' : '' }}>Sudah Dibayar</option>
          <option value="belum dibayar" {{ old('payment_status') == 'belum dibayar' ? 'selected' : '' }}>Belum Dibayar</option>
        </select>
        @error('payment_status') <span class="text-danger">{{ $message }}</span> @enderror
      </div>

      <!-- Status -->
      <div class="form-group">
        <label for="status" class="col-form-label">Status <span class="text-danger">*</span></label>
        <select name="status" class="form-control">
          <option value="pending" {{ old('status') == 'pending' ? 'selected' : '' }}>Pending</option>
          <option value="process" {{ old('status') == 'process' ? 'selected' : '' }}>Process</option>
          <option value="finished" {{ old('status') == 'finished' ? 'selected' : '' }}>Finished</option>
          <option value="cancel" {{ old('status') == 'cancel' ? 'selected' : '' }}>Cancel</option>
        </select>
        @error('status') <span class="text-danger">{{ $message }}</span> @enderror
      </div>

      <!-- First Name -->
      <div class="form-group">
        <label for="first_name" class="col-form-label">First Name <span class="text-danger">*</span></label>
        <input id="first_name" type="text" name="first_name" placeholder="Enter first name" value="{{ old('first_name') }}" class="form-control">
        @error('first_name') <span class="text-danger">{{ $message }}</span> @enderror
      </div>

      <!-- Last Name -->
      <div class="form-group">
        <label for="last_name" class="col-form-label">Last Name <span class="text-danger">*</span></label>
        <input id="last_name" type="text" name="last_name" placeholder="Enter last name" value="{{ old('last_name') }}" class="form-control">
        @error('last_name') <span class="text-danger">{{ $message }}</span> @enderror
      </div>

      <!-- Email -->
      <div class="form-group">
        <label for="email" class="col-form-label">Email <span class="text-danger">*</span></label>
        <input id="email" type="email" name="email" placeholder="Enter email" value="{{ old('email') }}" class="form-control">
        @error('email') <span class="text-danger">{{ $message }}</span> @enderror
      </div>

      <!-- Phone -->
      <div class="form-group">
        <label for="phone" class="col-form-label">Phone <span class="text-danger">*</span></label>
        <input id="phone" type="text" name="phone" placeholder="Enter phone number" value="{{ old('phone') }}" class="form-control">
        @error('phone') <span class="text-danger">{{ $message }}</span> @enderror
      </div>

      <!-- Address -->
      <div class="form-group">
        <label for="address" class="col-form-label">Address <span class="text-danger">*</span></label>
        <input id="address" type="text" name="address" placeholder="Enter address" value="{{ old('address') }}" class="form-control">
        @error('address') <span class="text-danger">{{ $message }}</span> @enderror
      </div>

      <!-- Submit Button -->
      <div class="form-group mb-3">
        <button type="reset" class="btn btn-warning">Reset</button>
        <button class="btn btn-success" type="submit">Submit</button>
      </div>
    </form>
  </div>
</div>

@endsection