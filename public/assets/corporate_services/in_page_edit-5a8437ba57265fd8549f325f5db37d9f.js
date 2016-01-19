(function() {
  this.InpageEditElement = (function() {
    function InpageEditElement(el1, object1, attribute1) {
      this.el = el1;
      this.object = object1;
      this.attribute = attribute1;
    }

    InpageEditElement.prototype.switch_to_edit = function(stash) {
      if (!_.isUndefined(this.attribute)) {
        if (stash) {
          this._stash();
        }
      }
      this.hide(this.text());
      return this.show(this.input());
    };

    InpageEditElement.prototype._stash = function() {
      if (!_.isArray(this.attribute)) {
        this.attribute = [this.attribute];
      }
      return _(this.attribute).each((function(_this) {
        return function(attr) {
          return _this.object.set('original_' + attr, _this.object.get(attr));
        };
      })(this));
    };

    InpageEditElement.prototype.switch_to_show = function() {
      this.load();
      if (!_.isUndefined(this.attribute)) {
        return this._restore();
      }
    };

    InpageEditElement.prototype.load = function() {
      this.show(this.text());
      return this.hide(this.input());
    };

    InpageEditElement.prototype._restore = function() {
      if (!_.isArray(this.attribute)) {
        this.attribute = [this.attribute];
      }
      return _(this.attribute).each((function(_this) {
        return function(attr) {
          if (!_.isUndefined(_this.object.get("original_" + attr))) {
            return _this.object.set(attr, _this.object.get("original_" + attr));
          }
        };
      })(this));
    };

    InpageEditElement.prototype.input_field = function() {
      return this.input().find('input');
    };

    InpageEditElement.prototype.input = function() {
      return $(this.el).find('.edit');
    };

    InpageEditElement.prototype.text = function() {
      return $(this.el).find('.no_edit');
    };

    InpageEditElement.prototype.text_width = function() {
      return this.text().find(':first-child').width();
    };

    InpageEditElement.prototype.show = function(element) {
      return element.addClass('in');
    };

    InpageEditElement.prototype.hide = function(element) {
      return element.removeClass('in');
    };

    return InpageEditElement;

  })();

  this.InpageEdit = (function() {
    function InpageEdit(options) {
      var node, validate;
      this.options = options;
      node = options.on;
      if (_.isFunction(options.object.validate)) {
        validate = true;
      } else {
        validate = false;
      }
      this.root = $(this.options.on).hasClass('editable_container') ? $(this.options.on) : $(this.options.on).find('.editable_container');
      $(this.options.on).find("[id$='_edit_start']").on('click', (function(_this) {
        return function(e) {
          var $target;
          e.stopPropagation();
          $target = $(e.target);
          if ($target.closest('.editable_container').get(0) === _this.root.get(0)) {
            _this.context = $target.closest('.editable_container');
            if (_.isFunction(_this.options.object.stash)) {
              _this.options.object.stash();
              _this.edit(false);
            } else {
              _this.edit(true);
            }
            _this.options.object.set('editing', true);
            _this.context.find(_this.options.focus_element).first().focus();
            if (_this.options.start_callback) {
              return _this.options.start_callback();
            }
          }
        };
      })(this));
      $(this.options.on).find("[id$='_edit_cancel']").on('click', (function(_this) {
        return function(e) {
          var $target;
          e.stopPropagation();
          $target = $(e.target);
          if ($target.closest('.editable_container').get(0) === _this.root.get(0)) {
            if (_.isFunction(_this.options.object.restore)) {
              _this.options.object.restore();
            }
            UserInput.reset();
            _this.options.object.set('editing', false);
            _this.context = $target.closest('.editable_container');
            return _this.show();
          }
        };
      })(this));
      $(this.options.on).find("[id$='_edit_save']").on('click', (function(_this) {
        return function(e) {
          var $target, data, url;
          e.stopPropagation();
          $target = $(e.target);
          if ($target.closest('.editable_container').get(0) === _this.root.get(0)) {
            if (validate && !_this.options.object.validate()) {
              return;
            }
            _this.context = $target.closest('.editable_container');
            url = _this.options.object.get('url');
            if (_.isFunction(_this.options.object.create_instance_attributes)) {
              data = _this.options.object.create_instance_attributes();
              data['_method'] = 'put';
            } else {
              data = _this.context.find(':input').serializeArray();
              data[data.length] = {
                name: '_method',
                value: 'put'
              };
            }
            if (_.isFunction(_this.options.object.update_persist)) {
              return _this.options.object.update_persist(_this._success, _this.options.error, _this);
            } else {
              return $.ajax({
                url: url,
                method: 'post',
                data: data,
                success: _this._success,
                error: _this.options.error,
                context: _this
              });
            }
          }
        };
      })(this));
    }

    InpageEdit.prototype._success = function(response, textStatus, jqXhr) {
      UserInput.reset();
      return this.options.success.apply(this, [response, textStatus, jqXhr]);
    };

    InpageEdit.prototype.off = function() {
      $('body').off('click', this.options.on + "_edit_start");
      $('body').off('click', this.options.on + "_edit_cancel");
      return $('body').off('click', this.options.on + "_edit_save");
    };

    InpageEdit.prototype.edit = function(stash) {
      _(this.elements()).each(function(el, i) {
        return el.switch_to_edit(stash);
      });
      UserInput.claim_user_input_request(this.options.object.edit, 'show');
      return this.options.object.set('editing', true);
    };

    InpageEdit.prototype.show = function() {
      this.options.object.remove_errors();
      _(this.elements()).each(function(el, i) {
        return el.switch_to_show();
      });
      return this.options.object.set('editing', false);
    };

    InpageEdit.prototype.load = function() {
      return _(this.elements()).each(function(el, i) {
        return el.load();
      });
    };

    InpageEdit.prototype.elements = function() {
      var all_elements, elements;
      this.context = $(this.options.on);
      all_elements = this.context.find("[data-toggle='edit']");
      elements = _(all_elements).filter((function(_this) {
        return function(el) {
          return $(el).closest('.editable_container').get(0) === _this.root.get(0);
        };
      })(this));
      return elements.map((function(_this) {
        return function(el, i) {
          var attribute, object;
          object = _this.options.object;
          attribute = $(el).data('attribute');
          return new InpageEditElement(el, object, attribute);
        };
      })(this));
    };

    return InpageEdit;

  })();

}).call(this);
