<!-- store-visit.blade.php -->
@extends('frontend.layouts.master')

@section('title', 'Pilih Jadwal Kedatangan')

@section('main-content')
<section class="shop checkout section">
    <div class="container">
        <h2>Pilih Jadwal Kedatangan Anda</h2>
        <form method="POST" action="{{route('store.visit.store')}}">
            @csrf
            <div class="form-group">
                <label for="visit_date">Pilih Tanggal Kedatangan</label>
                <input type="date" name="visit_date" id="visit_date" required class="form-control">
            </div>
            <button type="submit" class="btn">Konfirmasi Jadwal</button>
        </form>
    </div>
</section>
@endsection
