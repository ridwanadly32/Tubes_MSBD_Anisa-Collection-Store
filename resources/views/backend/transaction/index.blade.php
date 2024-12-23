@extends('backend.layouts.master')

@section('main-content')
<!-- DataTales Example -->
<div class="card shadow mb-4">
    <div class="row">
        <div class="col-md-12">
            @include('backend.layouts.notification')
        </div>
    </div>
    <div class="card-header py-3">
        <h6 class="m-0 font-weight-bold text-primary float-left">Transaction List</h6>
        <a href="{{route('transaction.create')}}" class="btn btn-primary btn-sm float-right" data-toggle="tooltip" data-placement="bottom" title="Add Transaction"><i class="fas fa-plus"></i> Add Transaction</a>
    </div>
    <div class="card-body">
        <div class="table-responsive">
            @if(count($transactions) > 0)
            <table class="table table-bordered" id="transaction-dataTable" width="100%" cellspacing="0">
                <thead>
                    <tr>
                        <th>S.N.</th>
                        <th>Transaction ID</th>
                        <th>Customer ID</th>
                        <th>Transaction Date</th>
                        <th>Total Amount</th>
                        <th>Status</th>
                        <th>Action</th>
                    </tr>
                </thead>
                <tbody>
                    @foreach($transactions as $transaction)
                    <tr>
                        <td>{{ $loop->iteration }}</td>
                        <td>{{ $transaction->transaction_id }}</td>
                        <td>{{ $transaction->customer_id }}</td>
                        <td>{{ $transaction->transaction_date }}</td>
                        <td>{{ number_format($transaction->total_amount, 2) }}</td>
                        <td>
                            @if($transaction->status == 'Completed')
                            <span class="badge badge-success">{{ $transaction->status }}</span>
                            @elseif($transaction->status == 'Pending')
                            <span class="badge badge-warning">{{ $transaction->status }}</span>
                            @else
                            <span class="badge badge-danger">{{ $transaction->status }}</span>
                            @endif
                        </td>
                        <td>
                            <a href="{{ route('transaction.edit', $transaction->transaction_id) }}" class="btn btn-primary btn-sm float-left mr-1" style="height:30px; width:30px;border-radius:50%" data-toggle="tooltip" title="Edit" data-placement="bottom"><i class="fas fa-edit"></i></a>
                            <form method="POST" action="{{ route('transaction.destroy', $transaction->transaction_id) }}">
                                @csrf
                                @method('delete')
                                <button class="btn btn-danger btn-sm dltBtn" data-id={{ $transaction->transaction_id }} style="height:30px; width:30px;border-radius:50%" data-toggle="tooltip" data-placement="bottom" title="Delete"><i class="fas fa-trash-alt"></i></button>
                            </form>
                        </td>
                    </tr>
                    @endforeach
                </tbody>
            </table>
            <span style="float:right">{{ $transactions->links() }}</span>
            @else
            <h6 class="text-center">No Transactions found!!! Please create a transaction.</h6>
            @endif
        </div>
    </div>
</div>
@endsection

@push('styles')
<link href="{{asset('backend/vendor/datatables/dataTables.bootstrap4.min.css')}}" rel="stylesheet">
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/sweetalert/1.1.3/sweetalert.min.css" />
<style>
    div.dataTables_wrapper div.dataTables_paginate {
        display: none;
    }
</style>
@endpush

@push('scripts')

<!-- Page level plugins -->
<script src="{{asset('backend/vendor/datatables/jquery.dataTables.min.js')}}"></script>
<script src="{{asset('backend/vendor/datatables/dataTables.bootstrap4.min.js')}}"></script>
<script src="https://cdnjs.cloudflare.com/ajax/libs/sweetalert/2.1.2/sweetalert.min.js"></script>

<!-- Page level custom scripts -->
<script src="{{asset('backend/js/demo/datatables-demo.js')}}"></script>
<script>
    $('#transaction-dataTable').DataTable({
        "columnDefs": [{
            "orderable": false,
            "targets": [4, 5, 6]
        }]
    });

    // Sweet alert
    $(document).ready(function() {
        $('.dltBtn').click(function(e) {
            var form = $(this).closest('form');
            var dataID = $(this).data('id');
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
