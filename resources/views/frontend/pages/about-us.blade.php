@extends('frontend.layouts.master')

@section('title','Anisa Collection Store || About Us')

@section('main-content')

	<!-- Breadcrumbs -->
	<div class="breadcrumbs">
		<div class="container">
			<div class="row">
				<div class="col-12">
					<div class="bread-inner">
						<ul class="bread-list">
							<li><a href="index1.html">Home<i class="ti-arrow-right"></i></a></li>
							<li class="active"><a href="blog-single.html">About Us</a></li>
						</ul>
					</div>
				</div>
			</div>
		</div>
	</div>
	<!-- End Breadcrumbs -->

	<!-- About Us -->
	<section class="about-us section">
			<div class="container">
				<div class="row">
					<div class="col-lg-6 col-12">
						<div class="about-content">
							{{-- @php
								$settings=DB::table('settings')->get();
							@endphp --}}
							<h3 style="line-height: 1.5; margin-top: 130px;">
								Selamat Datang di <span style="display: block;">Anisa Collection Store</span>
							  </h3>
							  
							  
							{{-- <p>@foreach($settings as $data) {{$data->description}} @endforeach</p> --}}
							<div class="button">
								{{-- <a href="{{route('blog')}}" class="btn">Our Blog</a> --}}
								<a href="{{route('contact')}}" class="btn primary">Contact Us</a>
							</div>
						</div>
					</div>
					<div class="col-lg-6 col-12">
						<div class="about-img overlay">
							{{-- <div class="button">
								<a href="https://www.youtube.com/watch?v=nh2aYrGMrIE" class="video video-popup mfp-iframe"><i class="fa fa-play"></i></a>
							</div> --}}
							<img src="backend/img/logo1_anisa.png" alt="..." class="img-fluid">
						</div>
					</div>
				</div>
			</div>
	</section>
	<!-- End About Us -->


	<!-- Start Shop Services Area  -->
{{-- <section class="shop-services section home">
    <div class="container">
        <div class="row">
            <div class="col-lg-3 col-md-6 col-12">
                <!-- Start Single Service -->
                <div class="single-service">
                    <i class="ti-rocket"></i>
                    <h4>Gratis Ongkir</h4>
                    <p>Pembelian diatas Rp100.000</p>
                </div>
                <!-- End Single Service -->
            </div>
            <div class="col-lg-3 col-md-6 col-12">
                <!-- Start Single Service -->
                <div class="single-service">
                    <i class="ti-reload"></i>
                    <h4>Pengembalian Gratis</h4>
                    <p>Garansi Pengembalian</p>
                </div>
                <!-- End Single Service -->
            </div>
            <div class="col-lg-3 col-md-6 col-12">
                <!-- Start Single Service -->
                <div class="single-service">
                    <i class="ti-lock"></i>
                    <h4>Pembayaran Aman</h4>
                    <p>Platform Terpercaya</p>
                </div>
                <!-- End Single Service -->
            </div>
            <div class="col-lg-3 col-md-6 col-12">
                <!-- Start Single Service -->
                <div class="single-service">
                    <i class="ti-tag"></i>
                    <h4>Harga Termurah</h4>
                    <p>Harga Dijamin Murah</p>
                </div>
                <!-- End Single Service -->
				</div>
			</div>
		</div>
	</section> --}}
	<!-- End Shop Services Area -->

	{{-- @include('frontend.layouts.newsletter')	 --}}
@endsection
