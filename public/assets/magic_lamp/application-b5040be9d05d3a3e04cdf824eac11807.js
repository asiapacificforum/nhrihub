(function(global) {
  var MagicLamp = {
    initialize: function() {
      this.genie = new this.Genie();
    },

    fixtureNames: function() {
      return this.genie.fixtureNames();
    },

    globalize: function() {
      window.clean = this.clean;
      window.load = this.load;
      window.loadJSON = this.loadJSON;
      window.loadRaw = this.loadRaw;
    },

    preload: function() {
      this.genie.preload.apply(this.genie, arguments);
    },

    genericError: 'Something went wrong, please check the server log, run `rake magic_lamp:lint`, or visit `/magic_lamp/lint` for more information'
  };

  MagicLamp.clean = function() {
    MagicLamp.genie.removeFixtureContainer();
  }

  MagicLamp.load = function() {
    MagicLamp.genie.load.apply(MagicLamp.genie, arguments);
  };

  MagicLamp.loadRaw = function() {
    return MagicLamp.genie.retrieveFixture.apply(MagicLamp.genie, arguments);
  };

  MagicLamp.loadJSON = function(fixtureName) {
    return JSON.parse(MagicLamp.loadRaw(fixtureName));
  };

  global.MagicLamp = MagicLamp;
})(this);

// aliases
MagicLamp.rub = MagicLamp.load;
MagicLamp.wish = MagicLamp.load;
MagicLamp.massage = MagicLamp.preload;
MagicLamp.wishForMoreWishes = MagicLamp.preload;
MagicLamp.polish = MagicLamp.clean;
(function(global) {

  function Genie() {
    this.cache = {};
    this.cacheOnly = false;
    this.namespace = MagicLamp;
  }

  Genie.prototype = {

    load: function() {
      this.removeFixtureContainer();
      this.createFixtureContainer();
      var fixture = '';
      var context = this;

      each(arguments, function(path) {
        fixture += context.retrieveFixture(path);
      });

      this.fixtureContainer.innerHTML = fixture;
      this.appendFixtureContainer();
    },

    retrieveFixture: function(path) {
      var fixture = this.cache[path];

      if (!fixture && this.cacheOnly) {
        throw new Error('The fixture "' + path + '" was not preloaded. Is the fixture registered? Call `MagicLamp.fixtureNames()` to see what is registered.');
      } else if (!fixture) {
        var xhr = this.xhrRequest(getPath() + '/' + path);
        this.cache[path] = fixture = xhr.responseText;
      }
      return fixture;
    },

    preload: function() {
      var xhr = this.xhrRequest(getPath());
      this.cache = JSON.parse(xhr.responseText);
      this.cacheOnly = true;
    },

    fixtureNames: function() {
      var names = [];
      for (fixtureName in this.cache) {
        if (this.cache.hasOwnProperty(fixtureName)) {
          names.push(fixtureName);
        }
      }
      var sortedNames = names.sort();
      each(sortedNames, function(name) {
        console.log(name);
      });

      return sortedNames;
    },

    createFixtureContainer: function() {
      var div = document.createElement('div');
      div.setAttribute('class', this.namespace.class || 'magic-lamp');
      this.fixtureContainer = div;
    },

    appendFixtureContainer: function() {
      document.body.appendChild(this.fixtureContainer);
    },

    removeFixtureContainer: function() {
      if (this.fixtureContainer) {
        remove(this.fixtureContainer);
        this.fixtureContainer = undefined;
      }
    },

    handleError: function(errorMessage) {
      throw new Error(errorMessage);
    },

    xhrRequest: function(path) {
      var xhr = newXhr();

      xhr.open('GET', path, false);
      xhr.send();

      if (this.xhrStatus(xhr) === 400) {
        this.handleError(xhr.responseText);
      } else if (this.xhrStatus(xhr) > 400) {
        this.handleError(MagicLamp.genericError);
      }
      return xhr;
    },

    xhrStatus: function(xhr) {
      return xhr.status;
    }
  };

  // private

  function getPath() {
    return MagicLamp.path || '/magic_lamp';
  }

  function remove(node) {
    var parentNode = node.parentNode;
    parentNode && parentNode.removeChild(node);
  }

  function each(collection, callback) {
    for (var i = 0; i < collection.length; i++) {
      callback(collection[i]);
    };
  }

  function newXhr() {
    var xhr;
    if (window.XMLHttpRequest) { // Mozilla, Safari, ...
      xhr = new XMLHttpRequest();
    } else if (window.ActiveXObject) { // IE
      try {
        xhr = new ActiveXObject('Msxml2.XMLHTTP');
      } catch (error) {
        try {
          xhr = new ActiveXObject('Microsoft.XMLHTTP');
        } catch (e) {
          // let it go
        }
      }
    }
    if (!xhr) {
      throw('Unable to make request');
    }
    return xhr;
  }

  MagicLamp.Genie = Genie;
})(this);
// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or vendor/assets/javascripts of plugins, if any, can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file.
//
// Read Sprockets README (https://github.com/sstephenson/sprockets#sprockets-directives) for details
// about supported directives.
//


;
