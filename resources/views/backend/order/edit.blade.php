@extends('backend.layouts.master')

@section('title','Order Detail')

@section('main-content')
<div class="card">
  <h5 class="card-header">Order Edit</h5>
  <div class="card-body">
    <form action="{{route('order.update',$order->id)}}" method="POST">
      @csrf
      @method('PATCH')
      <div class="form-group">
        <label for="status">Status Order:</label>
        <select name="status" id="" class="form-control">
            <option value="pending" {{($order->status=='finished' || $order->status=="process" || $order->status=="cancel") ? 'disabled' : ''}}  {{(($order->status=='pending')? 'selected' : '')}}>Pending</option>
            <option value="process" {{($order->status=='finished'|| $order->status=="cancel") ? 'disabled' : ''}}  {{(($order->status=='process')? 'selected' : '')}}>Process</option>
            <option value="finished" {{($order->status=="cancel") ? 'disabled' : ''}}  {{(($order->status=='finished')? 'selected' : '')}}>Finish</option>
            <option value="cancel" {{($order->status=='finished') ? 'disabled' : ''}}  {{(($order->status=='cancel')? 'selected' : '')}}>Cancel</option>
        </select>
    </div>
    
    <div class="form-group">
        <label for="payment_status">Status Pembayaran:</label>
        <select name="payment_status" id="" class="form-control">
           
          <!-- Status Pembayaran - Sudah Dibayar -->
<option value="belum dibayar" {{($order->payment_status == 'sudah dibayar') ? 'selected' : ''}}>Belum Dibayar</option>

<!-- Status Pembayaran - Belum Dibayar -->
<option value="sudah dibayar" {{($order->payment_status == 'belum dibayar') ? 'selected' : ''}}>Sudah Dibayar</option>

        </select>
    </div>
    
    <button type="submit" class="btn btn-primary">Update</button>
    
    </form>

      
  </div>
</div>
@endsection

@push('styles')
<style>
    .order-info,.shipping-info{
        background:#ECECEC;
        padding:20px;
    }
    .order-info h4,.shipping-info h4{
        text-decoration: underline;
    }

</style>
@endpush