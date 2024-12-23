@extends('user.layouts.master')

@section('title','Order Detail')

@section('main-content')
<div class="card">
<h5 class="card-header">Order   <a href="{{ route('order.pdf', $order->id) }}" class="btn btn-sm btn-primary shadow-sm float-right"><i class="fas fa-download fa-sm text-white-50"></i> Generate PDF</a>
</h5>
<div class="card-body">
  @if($order)
  <table class="table table-striped table-hover">
    <thead>
      <tr>
        <th>S.N.</th>
        <th>Order No.</th>
        <th>Name</th>
        <th>Email</th>
        {{-- <th>Quantity</th> --}}
        <th>Total Amount</th>
        <th>Status</th>
        <th>Action</th>
      </tr>
    </thead>
    <tbody>
      <tr>
        <td>{{ $order->id }}</td>
        <td>{{ $order->order_number }}</td>
        <td>{{ $order->first_name }} {{ $order->last_name }}</td>
        <td>{{ $order->email }}</td>
        {{-- <td>{{ $order->quantity }}</td> --}}
        <td>Rp{{ number_format($order->total_amount, 2) }}</td>
        <td>
          @if($order->status == 'pending')
            <span class="badge badge-primary">{{ $order->status }}</span>
          @elseif($order->status == 'process')
            <span class="badge badge-warning">{{ $order->status }}</span>
          @elseif($order->status == 'finished')
            <span class="badge badge-success">{{ $order->status }}</span>
          @else
            <span class="badge badge-danger">{{ $order->status }}</span>
          @endif
        </td>
        <td>
          <form method="POST" action="{{ route('order.destroy', [$order->id]) }}">
            @csrf
            @method('delete')
            <button class="btn btn-danger btn-sm dltBtn" data-id={{ $order->id }} style="height:30px; width:30px; border-radius:50%" data-toggle="tooltip" data-placement="bottom" title="Delete"><i class="fas fa-trash-alt"></i></button>
          </form>
        </td>
      </tr>
    </tbody>
  </table>

  <section class="confirmation_part section_padding">
    <div class="order_boxes">
      <div class="row">
        <div class="col-lg-6 col-lx-4">
          <div class="order-info">
            <h4 class="text-center pb-4">ORDER INFORMATION</h4>
            <table class="table">
              <tr>
                <td>Order Number</td>
                <td> : {{ $order->order_number }}</td>
              </tr>

              <tr>
                <td>Products</td>
                <td>: 
                    @foreach ($order->orderItems as $item)
                        {{ $item->product->title ?? 'Product not found' }} 
                        (Qty: {{ $item->quantity }})<br>
                        {{-- @if($item->product->discount > 0)
                            <small>Diskon: Rp{{ number_format($item->discount_amount, 2) }}</small><br>
                            <small>Harga Setelah Diskon: Rp{{ number_format($item->final_price, 2) }}</small>
                        @endif --}}
                    @endforeach
                </td>
            </tr>
            
            
            
            
            
            
            
            

              <tr>
                <td>Order Date</td>
                <td> : {{ $order->created_at->format('D d M, Y') }} at {{ $order->created_at->format('g : i a') }}</td>
              </tr>
              {{-- <tr>
                <td>Quantity</td>
                <td> : {{ $order->quantity }}</td>
              </tr> --}}
              <tr>
                <td>Order Status</td>
                <td> : {{ $order->status }}</td>
              </tr>

              <tr>
                <td>Total Amount</td>
                <td> : Rp {{ number_format($order->total_amount, 2) }}</td>
            </tr>
            
            
              
              <tr>
                <td>Payment Method</td>
                <td> : @if($order->payment_method == 'bayarditoko') Bayar Di Toko @else Transfer Bank @endif</td>
              </tr>
              <tr>
                <td>Payment Status</td>
                <td> : {{ $order->payment_status }}</td>
              </tr>
            </table>
          </div>
        </div>

        <!-- Remove shipping information -->
        <div class="col-lg-6 col-lx-4">
          <div class="shipping-info">
            <h4 class="text-center pb-4">PICKUP INFORMATION</h4>
            <table class="table">
              <tr>
                <td>Full Name</td>
                <td> : {{ $order->first_name }} {{ $order->last_name }}</td>
              </tr>
              <tr>
                <td>Email</td>
                <td> : {{ $order->email }}</td>
              </tr>
              <tr>
                <td>Phone No.</td>
                <td> : {{ $order->phone }}</td>
              </tr>
              <tr>
                <td>Address</td>
                <td> : {{ $order->address }} </td>
              </tr>
              {{-- <tr>
                <td>Country</td>
                <td> : {{ $order->country }}</td>
              </tr> --}}
              {{-- <tr>
                <td>Post Code</td>
                <td> : {{ $order->post_code }}</td>
              </tr> --}}
            </table>
          </div>
        </div>
      </div>
    </div>
  </section>
  @endif
</div>
</div>
@endsection

@push('styles')
<style>
  .order-info, .shipping-info {
    background: #ECECEC;
    padding: 20px;
  }
  .order-info h4, .shipping-info h4 {
    text-decoration: underline;
  }
</style>
@endpush