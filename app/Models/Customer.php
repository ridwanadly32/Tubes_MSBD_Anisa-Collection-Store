<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Customer extends Model
{
    use HasFactory;

    // Tentukan kolom primary key
    protected $primaryKey = 'customer_id'; // Tetapkan customer_id sebagai primary key

    // Tentukan kolom yang dapat diisi
    protected $fillable = ['name', 'phone', 'email', 'address'];
    

    
    public function transactions()
{
    return $this->hasMany(Transaction::class, 'customer_id', 'customer_id');
}

}
