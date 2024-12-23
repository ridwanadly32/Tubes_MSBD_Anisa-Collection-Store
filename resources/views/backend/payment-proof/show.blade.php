@extends('layouts.app')

@section('content')
    <div class="container" style="display: flex; justify-content: center; align-items: center; height: 100vh;">
        <img src="{{ asset('storage/' . $payment_proof) }}" style="max-width: 100%; max-height: 100%; object-fit: contain;" alt="Payment Proof">
    </div>
@endsection
