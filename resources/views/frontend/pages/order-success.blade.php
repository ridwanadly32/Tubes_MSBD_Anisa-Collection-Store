@extends('frontend.layouts.master')

@section('title', 'Order Success')

@section('main-content')
<div class="container my-5">
    <div class="row justify-content-center">
        <div class="col-md-8">
            <div class="card">
                <div class="card-body text-center">
                    <i class="fas fa-check-circle text-success" style="font-size: 48px;"></i>
                    <h2 class="my-4">Thank You For Your Order!</h2>
                    <p class="text-success">Your product successfully placed in order</p>
                    <div class="mt-4">
                        <a href="{{ route('home') }}" class="btn btn-primary">Continue Shopping</a>
                        <a href="{{ route('order.track') }}" class="btn btn-secondary">Track Order</a>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>
@endsection