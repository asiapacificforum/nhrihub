import $ from 'jquery'
export default { 'X-CSRF-TOKEN' : $('meta[name="csrf-token"]').attr('content') }
