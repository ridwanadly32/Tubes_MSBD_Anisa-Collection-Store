<!DOCTYPE html>
<html>
<head>
    <title>Order PDF</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            font-size: 12px;
        }
        .table {
            width: 100%;
            border-collapse: collapse;
        }
        .table th, .table td {
            border: 1px solid #ddd;
            padding: 8px;
        }
        .table th {
            background-color: #f4f4f4;
        }
    </style>
</head>
<body>
    <h1>Order Details</h1>
    <p><strong>Order Number:</strong> {{ $order->order_number }}</p>
    <p><strong>Name:</strong> {{ $order->first_name }} {{ $order->last_name }}</p>
    <p><strong>Email:</strong> {{ $order->email }}</p>
    <p><strong>Phone:</strong> {{ $order->phone }}</p>
    <p><strong>Address:</strong> {{ $order->address }}</p>
    <p><strong>Status:</strong> {{ $order->status }}</p>

    <h2>Products</h2>
    <table class="table">
        <thead>
            <tr>
                <th>Product</th>
                <th>Quantity</th>
                <th>Unit Price</th>
                <th>Subtotal</th>
            </tr>
        </thead>
        <tbody>
            @foreach ($order->orderItems as $item)
                <tr>
                    <td>{{ $item->product->title }}</td>
                    <td>{{ $item->quantity }}</td>
                    <td>Rp{{ number_format($item->unit_price, 0, ',', '.') }}</td>
                    <td>Rp{{ number_format($item->subtotal, 0, ',', '.') }}</td>
                </tr>
            @endforeach
        </tbody>
    </table>

    <h2>Summary</h2>
    <p><strong>Subtotal:</strong> Rp{{ number_format($order->sub_total, 0, ',', '.') }}</p>
    <p><strong>Shipping Cost:</strong> Rp{{ number_format($shippingCost, 0, ',', '.') }}</p>
    <p><strong>Total Amount:</strong> Rp{{ number_format($totalAmount, 0, ',', '.') }}</p>
</body>
</html>