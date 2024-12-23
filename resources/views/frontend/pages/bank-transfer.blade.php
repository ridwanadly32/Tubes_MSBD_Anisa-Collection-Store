@extends('frontend.layouts.master')
@section('title','Payment Details')
@section('main-content')
@if (session('success'))
    <div class="alert alert-success">
        {{ session('success') }}
    </div>
@endif

@if (session('error'))
    <div class="alert alert-danger">
        {{ session('error') }}
    </div>
@endif

<section class="section">
    <div class="container">
        <div class="row">
            <div class="col-12">
                <div class="card shadow-sm">
                    <div class="card-header text-white">
                        <h4>Informasi Pembayaran</h4>
                    </div>
                    <div class="card-body">
                        <!-- Tambahkan ID Order di Halaman -->
                        <div class="order-details mb-3">
                            <h5>Order ID: {{ $order->id }}</h5>
                        </div>
                        <!-- Bank Transfer Information -->
                        <div class="bank-details mb-5">
                            <h5>Transfer ke salah satu rekening berikut:</h5>
                            <div class="list-group">
                                <div class="list-group-item d-flex justify-content-between align-items-center">
                                    <h6>Bank BRI</h6>
                                    <p class="mb-0">No. Rek: 1234-5678-9012-3456</p>
                                    <p class="text-muted mb-0">A.N: Anisa Collection Store</p>
                                </div>
                                <div class="list-group-item d-flex justify-content-between align-items-center">
                                    <h6>Bank BNI</h6>
                                    <p class="mb-0">No. Rek: 9876-5432-1098-7654</p>
                                    <p class="text-muted mb-0">A.N: Anisa Collection Store</p>
                                </div>
                                <div class="list-group-item d-flex justify-content-between align-items-center">
                                    <h6>Bank BCA</h6>
                                    <p class="mb-0">No. Rek: 4567-8901-2345-6789</p>
                                    <p class="text-muted mb-0">A.N: Anisa Collection Store  </p>
                                </div>
                            </div>
                            
                            <h5 class="mt-4">E-Wallet:</h5>
                            <div class="list-group">
                                <div class="list-group-item d-flex justify-content-between align-items-center">
                                    <h6>GoPay</h6>
                                    <p class="mb-0">0812-3456-7890</p>
                                </div>
                                <div class="list-group-item d-flex justify-content-between align-items-center">
                                    <h6>DANA</h6>
                                    <p class="mb-0">0812-3456-7890</p>
                                </div>
                                <div class="list-group-item d-flex justify-content-between align-items-center">
                                    <h6>OVO</h6>
                                    <p class="mb-0">0812-3456-7890</p>
                                </div>
                                <div class="list-group-item d-flex justify-content-between align-items-center">
                                    <h6>ShopeePay</h6>
                                    <p class="mb-0">0812-3456-7890</p>
                                </div>
                            </div>
                        </div>

                        <!-- Upload Payment Proof -->
                        <form action="{{ route('payment.proof.upload') }}" method="POST" enctype="multipart/form-data">
                            @csrf
                            <input type="hidden" name="order_id" value="{{ $order->id }}">
                            <div class="form-group">
                                <label>Upload Bukti Transfer<span class="text-danger">*</span></label>
                                <input type="file" name="payment_proof" class="form-control" required accept="image/*">
                                @error('payment_proof')
                                    <span class="text-danger d-block mt-2">{{ $message }}</span>
                                @enderror
                            </div>
                            <button type="submit" class="btn btn-primary btn-block">Konfirmasi Pembayaran</button>
                        </form>
                        
                    </div>
                </div>
            </div>
        </div>
    </div>
</section>
@endsection


@push('styles')
    <style>

.card .card-header {
    background-color: #776B5D; /* Warna latar belakang */
    color: #fff; /* Warna teks */
    padding: 15px; /* Padding untuk jarak dalam */
    border-radius: 10px 10px 0 0; /* Sudut membulat pada bagian atas */
    font-weight: bold; /* Menekankan teks */
}

.card .card-header h4 {
    margin: 0; /* Menghapus margin default pada heading */
    font-size: 1.25rem; /* Ukuran font */
    text-align: center; /* Pusatkan teks */
    color: #fff; /* Warna teks harus serasi dengan latar belakang */
}

        .card {
            border-radius: 10px;
            margin-bottom: 20px;
        }
        .card-header {
            font-size: 1.25rem;
            font-weight: bold;
        }
        .list-group-item {
            border: none;
            padding: 15px 20px;
            border-radius: 8px;
            margin-bottom: 10px;
            background-color: #f8f9fa;
            box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
        }
        .list-group-item h6 {
            font-weight: bold;
        }
        .list-group-item .text-muted {
            font-size: 0.9rem;
        }
        .form-control {
            border-radius: 8px;
            padding: 12px;
            border: 1px solid #ddd;
        }
        .btn {
            padding: 12px;
            font-size: 1rem;
            border-radius: 8px;
            background-color: #776B5D;
            color: #fff;
            border: none;
        }
        .btn-block {
            width: 100%;
        }
        .form-group label {
            font-size: 1rem;
            font-weight: bold;
            margin-bottom: 8px;
        }
        .card-body {
            padding: 20px;
        }
        .bank-details h5, .form-group label {
            font-size: 1.15rem;
            font-weight: 600;
        }
        .form-control:focus {
            border-color: #776B5D;
            box-shadow: 0 0 5px rgba(0, 123, 255, 0.5);
        }
        .text-danger {
            font-size: 0.875rem;
        }
    </style>
@endpush
