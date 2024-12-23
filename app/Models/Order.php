<?php

namespace App\Models;
use Illuminate\Database\Eloquent\Model;

class Order extends Model
{
    protected $fillable=['user_id','product_id', 'order_number','sub_total','quantity','delivery_charge','status','total_amount','first_name','last_name','post_code','address','phone','email','payment_method','payment_status','coupon', 'payment_proof','pickup_date','shipping_id'
  ];

    public function cart_info(){
        return $this->hasMany('App\Models\Cart','order_id','id');
    }
    public static function getAllOrder($id){
        return Order::with('cart_info')->find($id);
    }
    public static function countActiveOrder(){
        $data=Order::count();
        if($data){
            return $data;
        }
        return 0;
    }
    public function cart(){
        return $this->hasMany(Cart::class);
    }

    public function shipping(){
        return $this->belongsTo(Shipping::class,'shipping_id');
    }
    public function user()
    {
        return $this->belongsTo('App\User', 'user_id');
    }

// Di model Order
public function products()
{
    return $this->belongsToMany(Product::class, 'order_product');
}

// Di model Product
public function orders()
{
    return $this->belongsToMany(Order::class, 'order_product');
}


public function orderItems()
{
    return $this->hasMany(OrderItem::class, 'order_id', 'id');
}



}