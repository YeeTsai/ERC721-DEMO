App = {
  web3Provider: null,
  contracts: {},

  init: function() {
    // Load pets.
    $.getJSON('../fishes.json', function(data) {
      var petsRow = $('#petsRow');
      var petTemplate = $('#petTemplate');

      for (i = 0; i < data.length; i ++) {
        petTemplate.find('.panel-title').text(data[i].name);
        petTemplate.find('img').attr('src', data[i].picture);
        petTemplate.find('.pet-age').text(data[i].price);

        petsRow.append(petTemplate.html());
      }
    })

    return App.initWeb3();
  },

  initWeb3: function() {
        // Is there an injected web3 instance?
        if (typeof web3 !== 'undefined') {
          App.web3Provider = web3.currentProvider;
        } else {
          // If no injected web3 instance is detected, fall back to Ganache
          App.web3Provider = new Web3.providers.HttpProvider('http://localhost:7545');
        }
        web3 = new Web3(App.web3Provider);
    
        return App.initContract()
  },

  initContract: function() {
    $.getJSON('FishCore.json', function(data) {
      // Get the necessary contract artifact file and instantiate it with truffle-contract
      var FishCoreArtifact = data;
      App.contracts.FishCore = TruffleContract(FishCoreArtifact);
    
      // Set the provider for our contract
      App.contracts.FishCore.setProvider(App.web3Provider);
    
      // Use our contract to retrieve and mark the adopted pets
      return App.getFishesPrice();
    });

    return App.bindEvents();
  },

  bindEvents: function() {
    //$(document).on('click', '.btn-adopt', App.handleAdopt);
  },

  getFishesPrice: function(account) {
    var fishInstance;

      App.contracts.FishCore.deployed().then(function(instance) {
        fishInstance = instance;
        return fishInstance.getFishesPrice.call();
      }).then(function(fishesPrice) {
        console.log(fishesPrice.length);
        for (i=0; i<fishesPrice.length; i++) {
          console.log("i" + i + "   price:" + fishesPrice[i].valueOf())
          $('.pet-age').eq(i).text(fishesPrice[i].valueOf());
        }
      }).catch(function(err) {
        console.log(err.message);
      });
  }
};

$(function() {
  $(window).load(function() {
    App.init();
  });
});
