@extends('frontend.layouts.master')

@section('title', 'Pembayaran')

@section('main-content')
<section class="shop checkout section">
    <div class="container">
        <h2>Informasi Pembayaran</h2>
        <p>Transfer ke salah satu rekening berikut:</p>
        <ul>
            <li>BRI: 123456789</li>
            <li>BNI: 987654321</li>
            <li>BCA: 456123789</li>
            <li>Gopay: 081234567890</li>
            <li>Dana: 081234567891</li>
        </ul>
        <form method="POST" action="{{ route('store.payment.save') }}" enctype="multipart/form-data">
            @csrf
            <div class="form-group">
                <label for="payment_proof">Upload Bukti Pembayaran:</label>
                <input type="file" name="payment_proof" required>
            </div>
            <button type="submit" class="btn">Upload Bukti Pembayaran</button>
        </form>
    </div>
</section>
@endsection
