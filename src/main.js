import Web3 from "web3"
import { newKitFromWeb3 } from "@celo/contractkit"
import BigNumber from "bignumber.js"
import DmusikMarketplaceAbi from "../contract/dmusik.abi.json"
import erc20Abi from "../contract/erc20.abi.json"
import { ERC20_DECIMALS, DmusikContractAddress, cUSDContractAddress } from './utils/constants';
import * as axios from 'axios';

let kit
let contract
let searchResult = [];
let searchQuery = document.getElementById("searchQuery");

// connect to celo
const connectCeloWallet = async function () {
    if (window.celo) {
        notification("⚠️ Please approve this DApp to use it.")
        try {
            await window.celo.enable()
            notificationOff()

            const web3 = new Web3(window.celo)
            kit = newKitFromWeb3(web3)

            const accounts = await kit.web3.eth.getAccounts()
            kit.defaultAccount = accounts[0]

            contract = new kit.web3.eth.Contract(DmusikMarketplaceAbi, DmusikContractAddress)
        } catch (error) {
            notification(`⚠️ ${error}.`)
        }
    } else {
        notification("⚠️ Please install the CeloExtensionWallet.")
    }
}

// approve transaction
async function approve(_price) {
    const cUSDContract = new kit.web3.eth.Contract(erc20Abi, cUSDContractAddress)

    const result = await cUSDContract.methods
        .approve(DmusikContractAddress, _price)
        .send({ from: kit.defaultAccount })
    return result
}

// get user balance
const getBalance = async function () {
    const totalBalance = await kit.getTotalBalance(kit.defaultAccount)
    const cUSDBalance = totalBalance.cUSD.shiftedBy(-ERC20_DECIMALS).toFixed(2)
    document.querySelector("#balance").textContent = `${cUSDBalance} cUSD`
}

// search on deezer
searchQuery.addEventListener('input', evt => {
    axios.get(`https://api.allorigins.win/raw?url=https://api.deezer.com/search?q=${searchQuery.value}`)
        .then(function (response) {
            let searchContainer = document.getElementById("searchContainer");

            if (evt.inputType == "deleteContentBackward") {
                searchResult = [];
                searchResult.length = 0;
                searchContainer.innerHTML = ""
            } else {
                let filteredResult = response.data.data.find(_search => _search.title.toLowerCase().includes(searchQuery.value.toLowerCase()));
                searchResult.push(filteredResult)
                searchResult.reverse().filter(async _search => {
                    const newDiv = document.createElement("ul")
                    newDiv.className = "search-list-ul"
                    newDiv.innerHTML = await searchResultTemplate(_search)
                    searchContainer.appendChild(newDiv)
                });
            };
        })
        .catch(function (error) {
            notification(error);
        });
});

// search template
async function searchResultTemplate(_search) {
    let likes = await contract.methods.getLikesCount(_search.id).call();
    return `
        <li class="search-list-li position-relative">
            <a href="${_search.link}" target="_blank" class="search-list-a">
                <img src="${_search.album.cover}" alt="${_search.album.title}" class="cover-image position-absolute">
                <div class="info position-absolute">
                    <span class="title">${_search.title}</span>
                    <br/>
                    <span class="artist">-${_search.artist.name}</span>
                    <br/>
                    <span class="likes">Likes - ${likes}</span>
                </div>
            </a>
            <div class="right-side position-absolute">
                <button onclick="likeSong(${_search.id})" class="like-dislike"><i class="far fa-thumbs-up"></i></button>
                <button onclick="supportSong(${_search.id})" class="support">support</button>
                <button onclick="playNow(${_search.id})" class="preview"><i class="fas fa-music"></i> Preview</button>
            </div>
            <audio id="playPreview${_search.id}">
                <source src="${_search.preview}" type="audio/mpeg">
            </audio>
        </li>
  `
}

// play and pause song preview
window.playNow = (song_id) => {
    let song = document.getElementById(`playPreview${song_id}`);
    song.paused ? song.play() : song.pause()
}

// like song and artist
window.likeSong = async (song_id) => {
    // getting data from api
    axios.get(`https://api.allorigins.win/raw?url=https://api.deezer.com/track/${song_id}`)
        .then(async function (response) {
            notification("⌛ Waiting for payment approval...")
            try {
                await approve(BigNumber(1).shiftedBy(ERC20_DECIMALS))
            } catch (error) {
                notification(`⚠️ ${error}.`)
            }
            notification(`⌛ Awaiting payment for "${response.data.album.title} by ${response.data.artist.name}"...`)
            try {
                await contract.methods
                    .likeSong(song_id, 1)
                    .send({ from: kit.defaultAccount })
                notification(`🎉 You successfully Liked "${response.data.album.title} by ${response.data.artist.name}" .`)
                getBalance()
            } catch (error) {
                notification(`⚠️ ${error}.`)
            }
        }).catch(function (error) {
            notification(error);
        })
}

// support song and artist
window.supportSong = (song_id) => {
    // getting data from api
    axios.get(`https://api.allorigins.win/raw?url=https://api.deezer.com/track/${song_id}`)
        .then(async function (response) {
            notification("⌛ Waiting for payment approval...")
            try {
                await approve(BigNumber(2).shiftedBy(ERC20_DECIMALS))
            } catch (error) {
                notification(`⚠️ ${error}.`)
            }
            notification(`⌛ Awaiting payment for "${response.data.album.title} by ${response.data.artist.name}"...`)
            try {
                await contract.methods
                    .dmusikSupport()
                    .send({ from: kit.defaultAccount })
                notification(`🎉 You successfully supported "${response.data.album.title} by ${response.data.artist.name}" .`)
                getBalance()
            } catch (error) {
                notification(`⚠️ ${error}.`)
            }
        }).catch(function (error) {
            notification(error);
        })
}

// notification on
function notification(_text) {
    document.querySelector(".alert").style.display = "block"
    document.querySelector("#notification").textContent = _text
}

// notification off
function notificationOff() {
    document.querySelector(".alert").style.display = "none"
}

// on load screen
window.addEventListener("load", async () => {
    notification("⌛ Loading...");
    await connectCeloWallet();
    await getBalance();
    notificationOff();
});