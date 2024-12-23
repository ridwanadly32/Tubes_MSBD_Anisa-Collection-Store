<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Category extends Model
{
    // Hapus 'is_parent', 'parent_id', dan 'added_by' dari kolom yang di-allowable
    protected $fillable = ['title', 'slug', 'summary', 'photo', 'status'];

    // Menghapus relasi yang melibatkan 'parent_id' dan 'is_parent'
    // Fungsi parent_info tidak diperlukan karena sudah dihapus kolom parent_id
    // public function parent_info(){
    //     return $this->hasOne('App\Models\Category','id','parent_id');
    // }

    // Memodifikasi method getAllCategory tanpa menggunakan parent_info
    public static function getAllCategory(){
        return Category::orderBy('id', 'DESC')->paginate(10); // Tidak ada relasi parent
    }

    // Fungsi shiftChild tidak lagi memerlukan 'is_parent'
    public static function shiftChild($cat_id){
        // Menghapus kolom 'is_parent' di sini karena sudah tidak ada di database
        return Category::whereIn('id', $cat_id)->update([]);
    }

    // Fungsi getChildByParentID tidak diperlukan lagi karena 'parent_id' sudah dihapus
    public static function getChildByParentID($id){
        // Tidak ada hubungan parent-child
        return [];
    }

    // Menghapus child_cat yang bergantung pada 'parent_id'
    public function child_cat(){
        // Menghilangkan pendefinisian 'parent_id' karena kolom tersebut sudah dihapus
        // Tidak ada lagi relasi berdasarkan parent_id, sehingga kita bisa menghapus relasi tersebut
        return $this->hasMany('App\Models\Category', 'id', 'id')->where('status', 'active');
    }
    

    // Mengubah getAllParentWithChild untuk tidak menggunakan 'is_parent'
    public static function getAllParentWithChild(){
        // Hapus logika untuk is_parent karena sudah tidak ada
        return Category::with('child_cat')->where('status', 'active')->orderBy('title', 'ASC')->get();
    }

    public function products(){
        return $this->hasMany('App\Models\Product', 'cat_id', 'id')->where('status', 'active');
    }
    public function sub_products(){
        return $this->hasMany('App\Models\Product', 'id', 'id')->where('status', 'active');
    }
    

    // Fungsi getProductByCat dan getProductBySubCat tidak terpengaruh
    public static function getProductByCat($slug){
        return Category::with('products')->where('slug', $slug)->first();
    }

    public static function getProductBySubCat($slug){
        return Category::with('sub_products')->where('slug', $slug)->first();
    }

    // Menghitung kategori yang aktif tanpa memerlukan 'is_parent'
    public static function countActiveCategory(){
        $data = Category::where('status', 'active')->count();
        if ($data) {
            return $data;
        }
        return 0;
    }
}
