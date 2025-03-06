// If you want to use Phoenix channels, run `mix help phx.gen.channel`
// to get started and then uncomment the line below.
import socket from "./user_socket.js"

// You can include dependencies in two ways.
//
// The simplest option is to put them in assets/vendor and
// import them using relative paths:
//
//     import "../vendor/some-package.js"
//
// Alternatively, you can `npm install some-package --prefix assets` and import
// them using a path starting with the package name:
//
//     import "some-package"
//

// Include phoenix_html to handle method=PUT/DELETE in forms and buttons.
import "phoenix_html"
// Establish Phoenix Socket and LiveView configuration.
import { Socket } from "phoenix"
import { LiveSocket } from "phoenix_live_view"
import topbar from "../vendor/topbar"

let csrfToken = document.querySelector("meta[name='csrf-token']").getAttribute("content")
let liveSocket = new LiveSocket("/live", Socket, {
  longPollFallbackMs: 2500,
  params: { _csrf_token: csrfToken }
})

// Show progress bar on live navigation and form submits
topbar.config({ barColors: { 0: "#29d" }, shadowColor: "rgba(0, 0, 0, .3)" })
window.addEventListener("phx:page-loading-start", _info => topbar.show(300))
window.addEventListener("phx:page-loading-stop", _info => topbar.hide())

// connect if there are any LiveViews on the page
liveSocket.connect()

// expose liveSocket on window for web console debug logs and latency simulation:
// >> liveSocket.enableDebug()
// >> liveSocket.enableLatencySim(1000)  // enabled for duration of browser session
// >> liveSocket.disableLatencySim()
window.liveSocket = liveSocket

// Custom Logic to insert a person to the list

const ul = document.getElementById('ronda');    // list of people.
const name = document.getElementById('name');   // name of the person.
const join = document.getElementById('join');   // join button.
const set_interval = document.getElementById('set_interval'); // set_interval button.
const interval = document.getElementById('interval');   // new interval.
const prev_turn_button = document.getElementById('prev_turn');
const next_turn_button = document.getElementById('next_turn');

const channel = socket.channel('ronda:lobby', {});  // connect to socket
channel.join()
  .receive("ok", resp => { console.log("Joined successfully", resp) })
  .receive("error", resp => { console.log("Unable to join", resp) });

// Listening to 'shout' events
channel.on('shout', function (payload) {
  render_message(payload)
});

channel.on('turn', function (payload) {
  // Find the element by id
  const selected_element = document.getElementById(`current-${payload.id}`);

  // Turn off all the other arrows
  const allElements = document.querySelectorAll('.hero-arrow-right-circle-mini');
  allElements.forEach(function (element) {
    if (element !== selected_element) {
      element.classList.remove('text-blue-500')
      element.classList.add('text-white')
    }
  });

  if (selected_element) {
    selected_element.classList.remove('text-white');
    selected_element.classList.add('text-blue-500');
  }
});

// Send the join signal to the server on "shout" channel
function joinRonda() {
  channel.push("current_id", {})  // Send a request to the server
    .receive("ok", (resp) => {
      channel.push('shout', {
        name: name.value,
        id: resp.id
      });
      console.log("Received current_id:", resp);
    })
}

// Render the message with Tailwind styles
function render_message(payload) {

  const li = document.createElement("li"); // create new list item DOM element

  // Message HTML with Tailwind CSS Classes for layout/style:
  li.innerHTML = `
  <div class="px-3 py-1 border-b border-gray-900">
    <p id="current-${payload.id}" class="hero-arrow-right-circle-mini"></p>
    <span>${payload.name}</span>
    <button id="remove-${payload.id}" class="text-red-500 hover:text-red-700 hero-trash-mini"></button>
    <button id="request-${payload.id}" class="text-green-500 hover:text-green-700 hero-arrow-path-mini"></button>
  </div>
  `

  if (payload.turn === payload.id) {
    li.querySelector(`#current-${payload.id}`).classList.add("text-blue-500");
  } else {
    li.querySelector(`#current-${payload.id}`).classList.add("text-white");
  }

  // Append to list
  ul.appendChild(li);
}

// Listen for the [Enter] keypress event to join:
name.addEventListener('keypress', function (event) {
  if (event.key === `Enter` && name.value.length > 0) {
    joinRonda()
  }
});

// On "Join"/"Quiero Mate!" button press
join.addEventListener('click', function (_) {
  if (name.value.length > 0) {
    joinRonda()
  }
});

// On "Set Interval" button press
set_interval.addEventListener('click', function (_) {
  const newInterval = parseInt(interval.value, 10);

  if (!isNaN(newInterval) && newInterval > 0) {
    // Ideally we should wait for a response before changing the page
    channel.push("set_interval", { interval: newInterval });
    const intervalDisplay = document.getElementById("interval_display");
    if (intervalDisplay) {
      intervalDisplay.textContent = `Intervalo: ${newInterval} [secs]`;
    }
  } else {
    console.error("Invalid interval. Please enter a valid number.");
  }
})

// On "<< Anterior" button press
prev_turn_button.addEventListener('click', function (_) {
  channel.push("turn_manual", { dir: 'prev' })  // Send a request to the server
});

// On "Siguiente >>" button press
next_turn_button.addEventListener('click', function (_) {
  channel.push("turn_manual", { dir: 'next' })  // Send a request to the server
});

document.addEventListener("click", (event) => {
  const button_remove = event.target.closest("button[id^='remove-']");
  const button_request_mate = event.target.closest("button[id^='request-']");
  if (button_remove) {
    // Extract the number from the ID (e.g., "remove-3" → "3")
    const id = button_remove.id.replace("remove-", "");
    console.log("Removing item with ID:", id);

    channel.push('remove_id', {
      id: id
    });

    // Remove the parent <li>
    button_remove.closest("li")?.remove();
  } else if (button_request_mate) {
    // Extract the number from the ID (e.g., "request-3" → "3")
    const id = button_request_mate.id.replace("request-", "");

    console.log("Requesting mate with ID:", id);

    channel.push('request_id', {
      id: id
    });
  } else {
    return;
  }
});
