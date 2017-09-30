module.exports = {
  oninit() {
    return this.set('selected',false);
  },
  toggle() {
    this.event.original.preventDefault();
    this.event.original.stopPropagation();
    return this.set('selected',!this.get('selected'));
  }
};

