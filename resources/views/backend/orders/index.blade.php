@extends('backend.layouts.master')

@section('main-content')
 <!-- DataTales Example -->
 <div class="image-modal" id="imageModal">
  <span class="close-modal" id="closeModal">&times;</span>
  <img id="modalImage" src="" alt="Payment Proof">
</div>
 <div class="card shadow mb-4">
     <div class="row">
         <div class="col-md-12">
            @include('backend.layouts.notification')
         </div>
     </div>
    <div class="card-header py-3">
      <h6 class="m-0 font-weight-bold text-primary float-left">Order Lists</h6>
    </div>
    <div class="card-body">
      <div class="table-responsive">
        @if(count($orders)>0)
        <table class="table table-bordered" id="order-dataTable" width="100%" cellspacing="0">
          <thead>
            <tr>
              <th>S.N.</th>
              <th>Order No.</th>
              <th>Name</th>
              <th>Email</th>
              {{-- <th>Quantity</th> --}}
              <th>Total Amount</th>
              <th>Payment Method</th>
              <th>Tanggal Ambil Barang</th>
              <th>Status</th>
              <th>Payment Proof</th> <!-- New column for payment proof -->
              <th>Action</th>
            </tr>
          </thead>
          <tfoot>
            <tr>
              <th>S.N.</th>
              <th>Order No.</th>
              <th>Name</th>
              <th>Email</th>
              {{-- <th>Quantity</th> --}}
              <th>Total Amount</th>
              <th>Payment Method</th>
              <th>Tanggal Ambil Barang</th>
              <th>Status</th>
              <th>Payment Proof</th> <!-- New column for payment proof -->
              <th>Action</th>
            </tr>
          </tfoot>
          <tbody>
            @foreach($orders as $order)  
                <tr>
                    <td>{{$order->id}}</td>
                    <td>{{$order->order_number}}</td>
                    <td>{{$order->first_name}} {{$order->last_name}}</td>
                    <td>{{$order->email}}</td>
                    {{-- <td>{{$order->quantity}}</td> --}}
                    <td>Rp{{number_format($order->total_amount, 2)}}</td>
                    <td>
                        @if($order->payment_method == 'bayarditoko')
                            Bayar Di Toko
                        @elseif($order->payment_method == 'transfer_bank')
                            Bank Transfer
                        @else
                            N/A
                        @endif
                    </td>
                    <td>{{$order->pickup_date}}</td>
                    <td>
                        @if($order->status == 'pending')
                          <span class="badge badge-primary">{{$order->status}}</span>
                        @elseif($order->status == 'process')
                          <span class="badge badge-warning">{{$order->status}}</span>
                        @elseif($order->status == 'finished')
                          <span class="badge badge-success">{{$order->status}}</span>
                        @else
                          <span class="badge badge-danger">{{$order->status}}</span>
                        @endif
                    </td>
                    <td>
                      @if($order->payment_proof)
                          <img src="{{ asset('storage/'.$order->payment_proof) }}" class="img-fluid payment-proof zoom" style="max-width:80px;" alt="Payment Proof">
                      @else
                          <span class="text-muted">No proof</span>
                      @endif
                  </td>
                    <td>
                        <a href="{{route('order.show', $order->id)}}" class="btn btn-warning btn-sm float-left mr-1" style="height:30px; width:30px;border-radius:50%" data-toggle="tooltip" title="view" data-placement="bottom"><i class="fas fa-eye"></i></a>
                        <a href="{{route('order.edit', $order->id)}}" class="btn btn-primary btn-sm float-left mr-1" style="height:30px; width:30px;border-radius:50%" data-toggle="tooltip" title="edit" data-placement="bottom"><i class="fas fa-edit"></i></a>
                        <form method="POST" action="{{route('order.destroy', [$order->id])}}">
                          @csrf 
                          @method('delete')
                              <button class="btn btn-danger btn-sm dltBtn" data-id={{$order->id}} style="height:30px; width:30px;border-radius:50%" data-toggle="tooltip" data-placement="bottom" title="Delete"><i class="fas fa-trash-alt"></i></button>
                        </form>
                    </td>
                </tr>  
            @endforeach
          </tbody>
        </table>
        <span style="float:right">{{$orders->links()}}</span>
        @else
          <h6 class="text-center">No orders found!!! Please order some products</h6>
        @endif
      </div>
    </div>
</div>
@endsection

@push('styles')
  <link href="{{asset('backend/vendor/datatables/dataTables.bootstrap4.min.css')}}" rel="stylesheet">
  <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/sweetalert/1.1.3/sweetalert.min.css" />
  <style>
      div.dataTables_wrapper div.dataTables_paginate{
          display: none;
      }

        /* Styling untuk gambar kecil */
    .payment-proof {
        transition: transform 0.3s ease-in-out;
        cursor: pointer;
        max-width: 80px;
    }

    /* Modal background */
    .image-modal {
        display: none;
        position: fixed;
        top: 0;
        left: 0;
        width: 100%;
        height: 100%;
        background-color: rgba(0, 0, 0, 0.8);
        z-index: 9999;
        justify-content: center;
        align-items: center;
    }

    /* Gambar besar di dalam modal */
    .image-modal img {
        max-width: 90%;
        max-height: 90%;
        box-shadow: 0 0 15px rgba(255, 255, 255, 0.5);
        transition: transform 0.3s ease-in-out;
    }

    /* Close button di modal */
    .image-modal .close-modal {
        position: absolute;
        top: 20px;
        right: 20px;
        color: #fff;
        font-size: 30px;
        cursor: pointer;
        z-index: 10000;
  }

  </style>

<script>
  document.addEventListener('DOMContentLoaded', function () {
      const images = document.querySelectorAll('.payment-proof');
      const modal = document.getElementById('imageModal');
      const modalImage = document.getElementById('modalImage');
      const closeModal = document.getElementById('closeModal');

      images.forEach(image => {
          image.addEventListener('click', function () {
              modalImage.src = this.src; // Ambil URL gambar yang di-klik
              modal.style.display = 'flex'; // Tampilkan modal
          });
      });

      closeModal.addEventListener('click', function () {
          modal.style.display = 'none'; // Sembunyikan modal
      });

      // Tutup modal jika area di luar gambar diklik
      modal.addEventListener('click', function (e) {
          if (e.target === modal) {
              modal.style.display = 'none';
          }
      });
  });
</script>
@endpush

@push('scripts')
  <!-- Page level plugins -->
  <script src="{{asset('backend/vendor/datatables/jquery.dataTables.min.js')}}"></script>
  <script src="{{asset('backend/vendor/datatables/dataTables.bootstrap4.min.js')}}"></script>
  <script src="https://cdnjs.cloudflare.com/ajax/libs/sweetalert/2.1.2/sweetalert.min.js"></script>

  <!-- Page level custom scripts -->
  <script src="{{asset('backend/js/demo/datatables-demo.js')}}"></script>
  <script>
      $('#order-dataTable').DataTable( {
            "columnDefs":[
                {
                    "orderable":false,
                    "targets":[9, 10]  // Disable sorting for the last two columns
                }
            ]
        } );

        // Sweet alert
        function deleteData(id){
            // Implement delete confirmation logic here
        }

      $(document).ready(function(){
        $.ajaxSetup({
            headers: {
                'X-CSRF-TOKEN': $('meta[name="csrf-token"]').attr('content')
            }
        });
        $('.dltBtn').click(function(e){
            var form=$(this).closest('form');
            var dataID=$(this).data('id');
            e.preventDefault();
            swal({
                title: "Are you sure?",
                text: "Once deleted, you will not be able to recover this data!",
                icon: "warning",
                buttons: true,
                dangerMode: true,
            })
            .then((willDelete) => {
                if (willDelete) {
                    form.submit();
                } else {
                    swal("Your data is safe!");
                }
            });
        })
      })
  </script>
@endpush