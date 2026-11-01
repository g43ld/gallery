const reducedMotion = window.matchMedia("(prefers-reduced-motion: reduce)");
const shaders = new Map();
const visibility = new Map();
let animationRequested = false;
let libraryPromise;

function loadLibrary() {
  if (!libraryPromise) {
    libraryPromise = new Promise((resolve, reject) => {
      const script = document.createElement("script");
      script.src = new URL("./glsl-canvas.js", import.meta.url).href;
      script.onload = () => resolve(window.GlslCanvas);
      script.onerror = reject;
      document.head.append(script);
    });
  }

  return libraryPromise;
}

function updatePlayback() {
  for (const [canvas, shader] of shaders) {
    const shouldPause = !animationRequested
      || document.hidden
      || reducedMotion.matches
      || visibility.get(canvas) === false;

    if (shouldPause) {
      shader.pause();
    } else {
      shader.play();
    }
  }
}

async function initialize(canvas) {
  if (shaders.has(canvas) || reducedMotion.matches) {
    return;
  }

  const GlslCanvas = await loadLibrary();
  if (shaders.has(canvas)) {
    return;
  }

  const shader = new GlslCanvas(canvas);
  if (shader.isValid) {
    shaders.set(canvas, shader);
    window.glslCanvases = [...shaders.values()];
    updatePlayback();
  }
}

function requestAnimation() {
  animationRequested = true;
  updatePlayback();
}

for (const eventName of ["keydown", "pointerdown", "pointermove", "touchstart"]) {
  window.addEventListener(eventName, requestAnimation, { once: true, passive: true });
}

const observer = new IntersectionObserver((entries) => {
  for (const entry of entries) {
    visibility.set(entry.target, entry.isIntersecting);
    if (entry.isIntersecting) {
      initialize(entry.target);
    }
  }
  updatePlayback();
}, { rootMargin: "50px" });

for (const canvas of document.querySelectorAll(".shader-runtime")) {
  visibility.set(canvas, false);
  observer.observe(canvas);
}

window.setTimeout(requestAnimation, 30000);
document.addEventListener("visibilitychange", updatePlayback);
reducedMotion.addEventListener("change", updatePlayback);
