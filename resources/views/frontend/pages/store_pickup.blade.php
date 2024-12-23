@extends('frontend.layouts.master')
@section('title','Pickup Schedule')
@section('main-content')
<section class="section">
    <div class="container">
        <div class="row">
            <div class="col-12">
                <div class="card">
                    <div class="card-header">
                        <h4>Tentukan Jadwal Pengambilan Barang</h4>
                    </div>
                    <div class="card-body">
                        <form action="{{ route('store.pickup.save') }}" method="POST">
                            @csrf
                            <div class="form-group">
                                <label>Tanggal Pengambilan<span class="text-danger">*</span></label>
                                <input type="date" name="pickup_date" class="form-control" required 
                                       min="{{ date('Y-m-d', strtotime('+1 day')) }}">
                            </div>
                            <button type="submit" class="btn btn-primary">Konfirmasi Jadwal</button>
                        </form>
                    </div>
                </div>
            </div>
        </div>
    </div>
</section>
@endsection