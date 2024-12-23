@extends('frontend.layouts.master')

@section('title','Checkout page')

@section('main-content')

    <!-- Breadcrumbs -->
    <div class="breadcrumbs">
        <div class="container">
            <div class="row">
                <div class="col-12">
                    <div class="bread-inner">
                        <ul class="bread-list">
                            <li><a href="{{route('home')}}">Home<i class="ti-arrow-right"></i></a></li>
                            <li class="active"><a href="javascript:void(0)">Checkout</a></li>
                        </ul>
                    </div>
                </div>
            </div>
        </div>
    </div>
    <!-- End Breadcrumbs -->
            
    <!-- Start Checkout -->
    <section class="shop checkout section">
        <div class="container">
                <form class="form" method="POST" action="{{route('cart.order')}}">
                    @csrf
                    <div class="row"> 

                        <div class="col-lg-8 col-12">
                            <div class="checkout-form">
                                <h2>Make Your Checkout Here</h2>
                                <p>Please register in order to checkout more quickly</p>
                                <!-- Form -->
                                <div class="row">
                                    <!-- Existing Fields (Nama Depan, Nama Belakang, etc.) -->
                                    <div class="col-lg-6 col-md-6 col-12">
                                        <div class="form-group">
                                            <label>Nama Depan<span>*</span></label>
                                            <input type="text" name="first_name" placeholder="" value="{{old('first_name')}}">
                                            @error('first_name')
                                                <span class='text-danger'>{{$message}}</span>
                                            @enderror
                                        </div>
                                    </div>
                                    <div class="col-lg-6 col-md-6 col-12">
                                        <div class="form-group">
                                            <label>Nama Belakang<span>*</span></label>
                                            <input type="text" name="last_name" placeholder="" value="{{old('last_name')}}">
                                            @error('last_name')
                                                <span class='text-danger'>{{$message}}</span>
                                            @enderror
                                        </div>
                                    </div>
                                    <div class="col-lg-6 col-md-6 col-12">
                                        <div class="form-group">
                                            <label>Alamat Email<span>*</span></label>
                                            <input type="email" name="email" placeholder="" value="{{old('email')}}">
                                            @error('email')
                                                <span class='text-danger'>{{$message}}</span>
                                            @enderror
                                        </div>
                                    </div>
                                    <div class="col-lg-6 col-md-6 col-12">
                                        <div class="form-group">
                                            <label>Nomor Telepon<span>*</span></label>
                                            <input type="number" name="phone" placeholder="" required value="{{old('phone')}}">
                                            @error('phone')
                                                <span class='text-danger'>{{$message}}</span>
                                            @enderror
                                        </div>
                                    </div>
                                    {{-- <div class="col-lg-6 col-md-6 col-12">
                                        <div class="form-group">
                                            <label>Negara<span>*</span></label>
                                            <select name="country" id="country">
                                                <option value="ID">Indonesia</option>
                                            </select>
                                        </div>
                                    </div> --}}
                                    <div class="col-lg-6 col-md-6 col-12">
                                        <div class="form-group">
                                            <label>Alamat<span>*</span></label>
                                            <input type="text" name="address" placeholder="" value="{{old('address')}}">
                                            @error('address')
                                                <span class='text-danger'>{{$message}}</span>
                                            @enderror
                                        </div>
                                    </div>

                                    <!-- Metode Pembayaran -->
                                    <div class="col-lg-6 col-md-6 col-12">
                                        <div class="form-group">
                                            <label>Metode Pembayaran<span>*</span></label>
                                            <select name="payment_method" id="payment_method" class="form-control" onchange="showPaymentDetails()">
                                                <option value="">Pilih Metode Pembayaran</option>
                                                <option value="transfer_bank">Transfer Bank</option>
                                                <option value="bayarditoko">Bayar Di Toko</option>
                                                {{-- <option value="cod">Cash On Delivery</option> --}}
                                            </select>
                                        </div>
                                    </div>

                                    <!-- Metode Pengiriman (only visible when 'Transfer Bank' is selected) -->
                                    <div id="shippingSection" class="col-lg-6 col-md-6 col-12" style="display: none;">
                                        <div class="form-group">
                                            <label for="shipping_id">Metode Pengiriman<span>*</span></label>
                                            <select name="shipping_id" class="form-control" id="shipping_id" onchange="updateShippingCost()">
                                                <option value="">Pilih Metode Pengiriman</option>
                                                @foreach(Helper::shipping() as $shipping)
                                                    <option value="{{$shipping->id}}" data-price="{{$shipping->price}}">
                                                        {{$shipping->type}}: Rp{{$shipping->price}}
                                                    </option>   
                                                @endforeach
                                            </select>
                                        </div>
                                    </div>

                                    <!-- Pickup Date (only visible when 'Bayar Di Toko' is selected) -->
                                    <div id="pickupDateSection" class="col-lg-6 col-md-6 col-12" style="display: none;">
                                        <div class="form-group">
                                            <label>Tanggal Pengambilan Barang<span>*</span></label>
                                            <input type="date" name="pickup_date" class="form-control">
                                        </div>
                                    </div>
                                    

                                    <!-- Shipping Cost (Visible when shipping method is selected) -->
                                    <div id="shippingCost" class="col-12" style="display: none;">
                                        <div class="form-group">
                                            <label>Biaya Pengiriman<span>*</span></label>
                                            <input type="text" name="shipping_cost" id="shippingCostValue" class="form-control" value="0" readonly>
                                        </div>
                                    </div>

                                </div>
                                <!--/ End Form -->
                            </div>
                        </div>

                        <!-- Order Details -->
                        <div class="col-lg-4 col-12">
                            <div class="order-details">
                                <!-- Order Widget -->
                                <div class="single-widget">
                                    <h2>CART  TOTALS</h2>
                                    <div class="content">
                                        <ul>
                                            <li class="order_subtotal" data-price="{{Helper::totalCartPrice()}}">
                                                Cart Subtotal<span>Rp{{number_format(Helper::totalCartPrice(),2)}}</span>
                                            </li>

                                            <!-- Shipping Cost -->
                                            <li class="shipping">
                                                Shipping Cost: <span id="shippingCostText">Rp0</span>
                                            </li>

                                            @if(session('coupon'))
                                                <li class="coupon_price" data-price="{{session('coupon')['value']}}">
                                                    You Save<span>Rp{{number_format(session('coupon')['value'],2)}}</span>
                                                </li>
                                            @endif

                                            @php
                                                $total_amount = Helper::totalCartPrice();
                                                if(session('coupon')){
                                                    $total_amount = $total_amount - session('coupon')['value'];
                                                }
                                            @endphp

                                            <li class="last" id="order_total_price">
                                                Total<span>Rp{{number_format($total_amount,2)}}</span>
                                            </li>
                                        </ul>
                                    </div>
                                </div>

                                <!-- Payment Method Widget -->
                                <div class="single-widget payement">
                                    <div class="content">
                                        <img src="{{('backend/img/payment-method.png')}}" alt="#">
                                    </div>
                                </div>

                                <!-- Button Widget -->
                                <div class="single-widget get-button">
                                    <div class="content">
                                        <div class="button">
                                            <button type="submit" class="btn">Buat Pesanan</button>
                                        </div>
                                    </div>
                                </div>
                                <!--/ End Button Widget -->
                            </div>
                        </div>
                    </div>
                </form>
        </div>
    </section>
    <!--/ End Checkout -->

    <!-- Scripts -->
    <script>
        // Function to display fields based on payment method
        function showPaymentDetails() {
            const paymentMethod = document.getElementById('payment_method').value;
            if (paymentMethod === 'transfer_bank') {
                document.getElementById('shippingSection').style.display = 'block';  // Show shipping options
                document.getElementById('pickupDateSection').style.display = 'none'; // Hide pickup date
            } else if (paymentMethod === 'bayarditoko') {
                document.getElementById('pickupDateSection').style.display = 'block';  // Show pickup date
                document.getElementById('shippingSection').style.display = 'none';    // Hide shipping options
            } else {
                document.getElementById('shippingSection').style.display = 'none';
                document.getElementById('pickupDateSection').style.display = 'none';
            }
        }

        // Function to update shipping cost when user selects shipping method
        function updateShippingCost() {
            const shippingSelect = document.getElementById('shipping_id');
            const selectedOption = shippingSelect.options[shippingSelect.selectedIndex];
            const shippingPrice = selectedOption.getAttribute('data-price');
            document.getElementById('shippingCostValue').value = shippingPrice;
            document.getElementById('shippingCostText').innerText = 'Rp' + shippingPrice;
            // document.getElementById('shipping_id').value = shippingId;
            
            // Update total price after shipping cost is applied
            const cartSubtotal = document.querySelector('.order_subtotal').getAttribute('data-price');
            const totalAmount = parseFloat(cartSubtotal) + parseFloat(shippingPrice);
            document.getElementById('order_total_price').innerHTML = `Total<span>Rp${totalAmount.toFixed(2)}</span>`;
        }
    </script>

@endsection