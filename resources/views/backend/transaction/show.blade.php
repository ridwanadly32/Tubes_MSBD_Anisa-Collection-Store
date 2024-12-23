@extends('backend.layouts.master')

@section('main-content')
    <div class="card shadow mb-4">
        <div class="card-header py-3">
            <h6 class="m-0 font-weight-bold text-primary">Transaction Details</h6>
        </div>
        <div class="card-body">
            <!-- All Transactions -->
            <h5>All Transactions</h5>
            <table class="table table-bordered">
                <thead>
                    <tr>
                        <th>Transaction ID</th>
                        <th>Customer ID</th>
                        <th>Transaction Date</th>
                        <th>Total Amount</th>
                        <th>Status</th>
                    </tr>
                </thead>
                <tbody>
                    @foreach($transactions as $trans)
                        <tr>
                            <td>{{ $trans->transaction_id }}</td>
                            <td>{{ $trans->customer_id }}</td>
                            <td>{{ $trans->transaction_date }}</td>
                            <td>{{ $trans->total_amount }}</td>
                            <td>{{ $trans->status }}</td>
                        </tr>
                    @endforeach
                </tbody>
            </table>


        </div>
    </div>
@endsection



