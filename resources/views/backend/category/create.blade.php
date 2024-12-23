@extends('backend.layouts.master')

@section('main-content')

<div class="card">
  <h5 class="card-header">Add Category</h5>
  <div class="card-body">
      <form method="post" action="{{ route('category.store') }}" enctype="multipart/form-data">
          {{ csrf_field() }}

          <!-- Title -->
          <div class="form-group">
              <label for="title" class="col-form-label">Category Title <span class="text-danger">*</span></label>
              <input id="title" type="text" name="title" placeholder="Enter category title" value="{{ old('title') }}" class="form-control">
              @error('title')
                  <span class="text-danger">{{ $message }}</span>
              @enderror
          </div>

          <!-- Slug (Auto-generated based on Title) -->
          <div class="form-group">
              <label for="slug" class="col-form-label">Slug <span class="text-danger">*</span></label>
              <input id="slug" type="text" name="slug" placeholder="Slug will be generated automatically" value="{{ old('slug') }}" class="form-control" readonly>
              @error('slug')
                  <span class="text-danger">{{ $message }}</span>
              @enderror
          </div>

          <!-- Summary -->
          <div class="form-group">
              <label for="summary" class="col-form-label">Summary</label>
              <textarea id="summary" name="summary" placeholder="Enter category summary" class="form-control">{{ old('summary') }}</textarea>
              @error('summary')
                  <span class="text-danger">{{ $message }}</span>
              @enderror
          </div>

          <!-- Photo -->
          <div class="form-group">
            <label for="inputPhoto" class="col-form-label">Photo</label>
            <div class="input-group">
                <span class="input-group-btn">
                    <a id="lfm" data-input="thumbnail" data-preview="holder" class="btn btn-primary">
                    <i class="fa fa-picture-o"></i> Choose
                    </a>
                </span>
            <input id="thumbnail" class="form-control" type="text" name="photo" value="{{old('photo')}}y">
          </div>
          <div id="holder" style="margin-top:15px;max-height:100px;"></div>
            @error('photo')
            <span class="text-danger">{{$message}}</span>
            @enderror
          </div>

          <!-- Parent Category -->
          {{-- <div class="form-group">
              <label for="parent_id" class="col-form-label">Parent Category</label>
              <select name="parent_id" class="form-control">
                  <option value="">Select Parent Category</option>
                  @foreach($parent_cats as $cat)
                      <option value="{{ $cat->id }}" {{ old('parent_id') == $cat->id ? 'selected' : '' }}>
                          {{ $cat->title }}
                      </option>
                  @endforeach
              </select>
              @error('parent_id')
                  <span class="text-danger">{{ $message }}</span>
              @enderror
          </div> --}}

          <!-- Is Parent (Checkbox) -->
          {{-- <div class="form-group">
              <label for="is_parent" class="col-form-label">Is Parent Category?</label>
              <input type="checkbox" name="is_parent" value="1" {{ old('is_parent') == 1 ? 'checked' : '' }} class="form-check-input">
              @error('is_parent')
                  <span class="text-danger">{{ $message }}</span>
              @enderror
          </div> --}}

          <!-- Status -->
          <div class="form-group">
              <label for="status" class="col-form-label">Status <span class="text-danger">*</span></label>
              <select name="status" class="form-control">
                  <option value="active" {{ old('status') == 'active' ? 'selected' : '' }}>Active</option>
                  <option value="inactive" {{ old('status') == 'inactive' ? 'selected' : '' }}>Inactive</option>
              </select>
              @error('status')
                  <span class="text-danger">{{ $message }}</span>
              @enderror
          </div>

          <!-- Buttons -->
          <div class="form-group mb-3">
              <button type="reset" class="btn btn-warning">Reset</button>
              <button class="btn btn-success" type="submit">Submit</button>
          </div>
      </form>
  </div>
</div>

@endsection

@section('scripts')
<script>
  // Secara otomatis menghasilkan slug dari judul
  document.getElementById('title').addEventListener('input', function() {
      var title = this.value;
      var slug = title.toLowerCase().replace(/[^a-z0-9]+/g, '-').replace(/^-|-$/g, '');
      document.getElementById('slug').value = slug;
  });
</script>
@endsection

@push('scripts')
<script src="/vendor/laravel-filemanager/js/stand-alone-button.js"></script>
<script src="{{asset('backend/summernote/summernote.min.js')}}"></script>
<script>
    $('#lfm').filemanager('image');

</script>
@endpush
