const note = new Ractive({
  el : '#single_note',
  template : `
    <div class='modal fade' id='single_note_modal' role='dialog'>
     <div class='modal-dialog' role='document'>
       <div class='modal-content'>
         <div class='modal-header'>
           <h4 class='modal-title' id='myModalLabel'>
             Note
             <button class='close' type='button' data-dismiss='modal'>
               <span>&times;</span>
             </button>
           </h4>
         </div>
         <div class='modal-body'>
           <div class='note_text'>
             {{note}}
           </div>
         </div>
       </div>
     </div>
    </div> `
});

module.exports= {
  show_note() {
    note.set({
      note : this.get('note')});
    return $('#single_note_modal').modal('show');
  }
};
