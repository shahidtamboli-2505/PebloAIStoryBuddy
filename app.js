/**
 * Peblo AI Story Buddy — Application Logic
 * 
 * Implements the full state machine, Web Speech API narration,
 * quiz logic, confetti animation, and all UI state transitions.
 */

// ============================================================
// State Machine
// ============================================================
const StoryState = {
  IDLE: 'idle',
  LOADING: 'loading',
  SPEAKING: 'speaking',
  AUDIO_COMPLETE: 'audioComplete',
  QUIZ_VISIBLE: 'quizVisible',
  SUCCESS: 'success',
  ERROR: 'error',
};

// ============================================================
// Story & Quiz Data
// ============================================================
const STORY_TEXT =
  'Once upon a time, a clever little robot named Pip lost his shiny blue ' +
  'gear in the Whispering Woods. He searched high and low, asking the ' +
  'friendly fireflies and wise old owls for help. After a great adventure, ' +
  'Pip finally found his gear sparkling under a mushroom, guarded by a ' +
  'tiny sleeping snail. Pip thanked everyone and rolled home happily, ' +
  'his gears spinning bright!';

const QUIZ_DATA = {
  question: "What colour was Pip the Robot's lost gear?",
  options: ['Red', 'Green', 'Blue', 'Yellow'],
  answer: 'Blue',
};

// ============================================================
// App State
// ============================================================
let currentState = StoryState.IDLE;
let selectedAnswer = null;
let hasAnswered = false;
let isCorrect = false;
let wrongAttempts = 0;
let speechSynth = null;
let currentUtterance = null;

// ============================================================
// DOM Elements
// ============================================================
const $ = (id) => document.getElementById(id);

const appBackground = $('app-background');
const buddyWrapper = $('buddy-wrapper');
const antennaBall = $('antenna-ball');
const robotHead = $('robot-head');
const eyeLeft = $('eye-left');
const eyeRight = $('eye-right');
const pupilLeft = $('pupil-left');
const pupilRight = $('pupil-right');
const mouth = $('mouth');
const speechBubble = $('speech-bubble');
const speechText = $('speech-text');
const storyCardBorder = $('story-card-border');
const bookIcon = $('book-icon');
const storyHeaderText = $('story-header-text');
const storyTextEl = $('story-text');
const buttonContainer = $('button-container');
const readStoryBtn = $('read-story-btn');
const btnIcon = $('btn-icon');
const btnLabel = $('btn-label');
const quizSection = $('quiz-section');
const quizQuestion = $('quiz-question');
const quizOptions = $('quiz-options');
const quizFeedback = $('quiz-feedback');
const successCard = $('success-card');
const playAgainBtn = $('play-again-btn');
const errorSection = $('error-section');
const confettiCanvas = $('confetti-canvas');

// ============================================================
// Speech Bubble Messages
// ============================================================
const SPEECH_MESSAGES = {
  [StoryState.IDLE]: 'Hi there! Ready for a story? 🌟',
  [StoryState.LOADING]: 'Let me warm up my voice... 🎤',
  [StoryState.SPEAKING]: 'Listen closely! 🎧',
  [StoryState.AUDIO_COMPLETE]: 'Story done! Quiz time... 🧠',
  [StoryState.QUIZ_VISIBLE]: 'Can you answer this? 🤔',
  [StoryState.SUCCESS]: "You're a genius! 🎉",
  [StoryState.ERROR]: 'Oh no, let\'s try again! 😅',
};

// ============================================================
// State Transition
// ============================================================
function setState(newState) {
  const prevState = currentState;
  currentState = newState;
  updateUI(prevState, newState);
}

// ============================================================
// UI Update Engine
// ============================================================
function updateUI(prevState, state) {
  // -- Background --
  appBackground.className = 'app-background';
  if (state === StoryState.SPEAKING) appBackground.classList.add('speaking');
  else if (state === StoryState.SUCCESS) appBackground.classList.add('success');
  else if (state === StoryState.ERROR) appBackground.classList.add('error');

  // -- Antenna Ball --
  antennaBall.className = 'antenna-ball';
  if (state === StoryState.SPEAKING) antennaBall.classList.add('speaking');
  else if (state === StoryState.SUCCESS) antennaBall.classList.add('success');
  else if (state === StoryState.ERROR) antennaBall.classList.add('error');

  // -- Robot Head --
  robotHead.className = 'robot-head';
  if (state === StoryState.SUCCESS) robotHead.classList.add('success');
  else if (state === StoryState.ERROR) robotHead.classList.add('error');

  // -- Eyes --
  const eyeClasses = ['speaking', 'happy', 'loading'];
  [eyeLeft, eyeRight].forEach((eye) => {
    eyeClasses.forEach((c) => eye.classList.remove(c));
    if (state === StoryState.SPEAKING) eye.classList.add('speaking');
    else if (state === StoryState.SUCCESS) eye.classList.add('happy');
    else if (state === StoryState.LOADING) eye.classList.add('loading');
  });

  // -- Mouth --
  mouth.className = 'mouth';
  if (state === StoryState.SPEAKING) mouth.classList.add('speaking');
  else if (state === StoryState.SUCCESS) mouth.classList.add('success');
  else if (state === StoryState.ERROR) mouth.classList.add('sad');

  // -- Speech Bubble --
  updateSpeechBubble(state);

  // -- Story Card --
  storyCardBorder.className = 'story-card-border';
  bookIcon.className = 'book-icon';
  storyHeaderText.className = 'story-header-text';
  storyTextEl.className = 'story-text';
  if (state === StoryState.SPEAKING) {
    storyCardBorder.classList.add('speaking');
    bookIcon.classList.add('speaking');
    storyHeaderText.classList.add('speaking');
    storyHeaderText.textContent = '📖  Narrating...';
    storyTextEl.classList.add('speaking');
  } else {
    storyHeaderText.textContent = "📖  Pip's Story";
  }

  // -- Button --
  updateButton(state);

  // -- Quiz Section --
  if (state === StoryState.QUIZ_VISIBLE) {
    quizSection.classList.add('visible');
    renderQuiz();
  } else if (state !== StoryState.QUIZ_VISIBLE) {
    quizSection.classList.remove('visible');
  }

  // -- Success Card --
  if (state === StoryState.SUCCESS) {
    successCard.classList.add('visible');
    startConfetti();
  } else {
    successCard.classList.remove('visible');
  }

  // -- Error Section --
  if (state === StoryState.ERROR) {
    errorSection.classList.add('visible');
  } else {
    errorSection.classList.remove('visible');
  }
}

function updateSpeechBubble(state) {
  const msg = SPEECH_MESSAGES[state] || SPEECH_MESSAGES[StoryState.IDLE];
  if (speechText.textContent !== msg) {
    speechBubble.style.opacity = '0';
    speechBubble.style.transform = 'translateY(8px)';
    setTimeout(() => {
      speechText.textContent = msg;
      speechBubble.style.opacity = '1';
      speechBubble.style.transform = 'translateY(0)';
    }, 200);
  }
}

function updateButton(state) {
  readStoryBtn.className = 'read-story-btn';
  btnIcon.className = 'btn-icon';

  const hideButton =
    state === StoryState.QUIZ_VISIBLE || state === StoryState.SUCCESS;

  if (hideButton) {
    buttonContainer.style.display = 'none';
    return;
  }
  buttonContainer.style.display = '';

  switch (state) {
    case StoryState.LOADING:
      readStoryBtn.classList.add('disabled');
      btnIcon.classList.add('loading');
      btnIcon.textContent = '';
      btnLabel.textContent = 'Preparing...';
      break;
    case StoryState.SPEAKING:
      readStoryBtn.classList.add('disabled');
      btnIcon.textContent = '🔊';
      btnLabel.textContent = 'Listening... 🎧';
      break;
    case StoryState.ERROR:
      readStoryBtn.classList.add('error-state');
      btnIcon.textContent = '🔄';
      btnLabel.textContent = 'Try Again 🔄';
      break;
    default:
      btnIcon.textContent = '▶';
      btnLabel.textContent = 'Read Me a Story! 📖';
      break;
  }
}

// ============================================================
// Text-to-Speech (Web Speech API)
// ============================================================
function initTTS() {
  if (!('speechSynthesis' in window)) {
    console.warn('Speech Synthesis not supported.');
    return false;
  }
  speechSynth = window.speechSynthesis;
  return true;
}

function startNarration() {
  if (
    currentState === StoryState.SPEAKING ||
    currentState === StoryState.LOADING
  ) {
    return;
  }

  setState(StoryState.LOADING);

  if (!initTTS()) {
    setState(StoryState.ERROR);
    return;
  }

  // Cancel any ongoing speech
  speechSynth.cancel();

  const utterance = new SpeechSynthesisUtterance(STORY_TEXT);
  utterance.lang = 'en-US';
  utterance.rate = 0.85; // Kid-friendly slower pace
  utterance.pitch = 1.15; // Slightly higher, friendly tone
  utterance.volume = 1.0;

  // Try to pick a good voice
  const voices = speechSynth.getVoices();
  const preferredVoice = voices.find(
    (v) =>
      v.lang.startsWith('en') &&
      (v.name.includes('Female') ||
        v.name.includes('Samantha') ||
        v.name.includes('Google') ||
        v.name.includes('Microsoft Zira'))
  );
  if (preferredVoice) {
    utterance.voice = preferredVoice;
  }

  utterance.onstart = () => {
    setState(StoryState.SPEAKING);
  };

  utterance.onend = () => {
    setState(StoryState.AUDIO_COMPLETE);
    setTimeout(() => {
      if (currentState === StoryState.AUDIO_COMPLETE) {
        setState(StoryState.QUIZ_VISIBLE);
      }
    }, 600);
  };

  utterance.onerror = (event) => {
    if (event.error !== 'canceled') {
      setState(StoryState.ERROR);
    }
  };

  currentUtterance = utterance;

  // Small delay to show loading state
  setTimeout(() => {
    speechSynth.speak(utterance);
  }, 300);
}

// ============================================================
// Quiz Rendering & Logic
// ============================================================
function renderQuiz() {
  quizQuestion.textContent = QUIZ_DATA.question;
  quizOptions.innerHTML = '';
  quizFeedback.textContent = '';
  quizFeedback.className = 'quiz-feedback';

  QUIZ_DATA.options.forEach((option, index) => {
    const optionEl = document.createElement('div');
    optionEl.className = 'quiz-option';
    optionEl.id = `quiz-option-${index}`;
    optionEl.setAttribute('role', 'button');
    optionEl.setAttribute('tabindex', '0');

    const badge = document.createElement('div');
    badge.className = 'option-badge';
    badge.textContent = String.fromCharCode(65 + index); // A, B, C, D

    const text = document.createElement('span');
    text.className = 'option-text';
    text.textContent = option;

    optionEl.appendChild(badge);
    optionEl.appendChild(text);

    optionEl.addEventListener('click', () => handleQuizAnswer(option, optionEl));
    optionEl.addEventListener('keydown', (e) => {
      if (e.key === 'Enter' || e.key === ' ') {
        e.preventDefault();
        handleQuizAnswer(option, optionEl);
      }
    });

    quizOptions.appendChild(optionEl);
  });
}

function handleQuizAnswer(answer, optionEl) {
  // Don't allow re-answering after correct
  if (hasAnswered && isCorrect) return;

  selectedAnswer = answer;
  hasAnswered = true;
  isCorrect = QUIZ_DATA.answer === answer;

  // Reset all options
  document.querySelectorAll('.quiz-option').forEach((el) => {
    el.classList.remove('correct', 'incorrect');
  });

  if (isCorrect) {
    optionEl.classList.add('correct');
    optionEl.querySelector('.option-badge').textContent = '✓';

    // Disable all options
    document.querySelectorAll('.quiz-option').forEach((el) => {
      el.classList.add('disabled');
    });

    quizFeedback.textContent = '';

    // Transition to success
    setTimeout(() => {
      setState(StoryState.SUCCESS);
    }, 600);
  } else {
    wrongAttempts++;
    optionEl.classList.add('incorrect');
    optionEl.querySelector('.option-badge').textContent = '✗';

    // Shake the quiz
    quizSection.querySelector('.quiz-border').classList.add('shake');
    setTimeout(() => {
      quizSection.querySelector('.quiz-border').classList.remove('shake');
    }, 500);

    quizFeedback.textContent = 'Oops! Try again 💪';
    quizFeedback.className = 'quiz-feedback wrong';

    // Clear after delay
    setTimeout(() => {
      if (!isCorrect) {
        optionEl.classList.remove('incorrect');
        optionEl.querySelector('.option-badge').textContent = String.fromCharCode(
          65 + QUIZ_DATA.options.indexOf(answer)
        );
        quizFeedback.textContent = '';
        quizFeedback.className = 'quiz-feedback';
        hasAnswered = false;
        selectedAnswer = null;
      }
    }, 1200);
  }
}

// ============================================================
// Confetti Animation (Canvas-based)
// ============================================================
const confettiColors = [
  '#7C4DFF', '#FF9100', '#00E676', '#2979FF', '#FF6B6B', '#FFD740',
  '#E040FB', '#00BCD4', '#FF4081',
];
let confettiParticles = [];
let confettiAnimFrame = null;
let confettiRunning = false;

function initConfettiCanvas() {
  const ctx = confettiCanvas.getContext('2d');
  function resize() {
    confettiCanvas.width = window.innerWidth;
    confettiCanvas.height = window.innerHeight;
  }
  resize();
  window.addEventListener('resize', resize);
  return ctx;
}

const confettiCtx = initConfettiCanvas();

function createConfettiParticle() {
  return {
    x: Math.random() * confettiCanvas.width,
    y: -20 - Math.random() * 40,
    w: 8 + Math.random() * 6,
    h: 5 + Math.random() * 4,
    color: confettiColors[Math.floor(Math.random() * confettiColors.length)],
    vx: (Math.random() - 0.5) * 6,
    vy: 2 + Math.random() * 4,
    rotation: Math.random() * 360,
    rotationSpeed: (Math.random() - 0.5) * 12,
    opacity: 1,
    decay: 0.003 + Math.random() * 0.004,
  };
}

function startConfetti() {
  if (confettiRunning) return;
  confettiRunning = true;
  confettiParticles = [];

  // Burst: spawn many particles
  for (let i = 0; i < 80; i++) {
    const p = createConfettiParticle();
    // Burst from center-top
    p.x = confettiCanvas.width / 2 + (Math.random() - 0.5) * 200;
    p.y = confettiCanvas.height * 0.15 + (Math.random() - 0.5) * 60;
    p.vx = (Math.random() - 0.5) * 14;
    p.vy = -4 + Math.random() * 8;
    confettiParticles.push(p);
  }

  animateConfetti();

  // Stop after 3 seconds
  setTimeout(() => {
    confettiRunning = false;
  }, 3000);
}

function animateConfetti() {
  confettiCtx.clearRect(0, 0, confettiCanvas.width, confettiCanvas.height);

  confettiParticles = confettiParticles.filter((p) => p.opacity > 0.01);

  confettiParticles.forEach((p) => {
    p.x += p.vx;
    p.vy += 0.15; // gravity
    p.y += p.vy;
    p.rotation += p.rotationSpeed;
    p.opacity -= p.decay;
    p.vx *= 0.99;

    confettiCtx.save();
    confettiCtx.translate(p.x, p.y);
    confettiCtx.rotate((p.rotation * Math.PI) / 180);
    confettiCtx.globalAlpha = Math.max(0, p.opacity);
    confettiCtx.fillStyle = p.color;

    // Draw as rectangle (confetti piece)
    confettiCtx.fillRect(-p.w / 2, -p.h / 2, p.w, p.h);
    confettiCtx.restore();
  });

  if (confettiParticles.length > 0) {
    confettiAnimFrame = requestAnimationFrame(animateConfetti);
  } else {
    confettiCtx.clearRect(0, 0, confettiCanvas.width, confettiCanvas.height);
  }
}

function stopConfetti() {
  confettiRunning = false;
  confettiParticles = [];
  if (confettiAnimFrame) cancelAnimationFrame(confettiAnimFrame);
  confettiCtx.clearRect(0, 0, confettiCanvas.width, confettiCanvas.height);
}

// ============================================================
// Reset Everything
// ============================================================
function resetApp() {
  // Stop TTS
  if (speechSynth) speechSynth.cancel();

  // Reset quiz state
  selectedAnswer = null;
  hasAnswered = false;
  isCorrect = false;
  wrongAttempts = 0;

  // Stop confetti
  stopConfetti();

  // Reset to idle
  setState(StoryState.IDLE);
}

// ============================================================
// Event Listeners
// ============================================================
readStoryBtn.addEventListener('click', () => {
  if (currentState === StoryState.SPEAKING || currentState === StoryState.LOADING) {
    return;
  }
  if (currentState === StoryState.ERROR) {
    resetApp();
    setTimeout(() => startNarration(), 300);
  } else {
    startNarration();
  }
});

playAgainBtn.addEventListener('click', () => {
  resetApp();
});

// Load voices (some browsers load them asynchronously)
if ('speechSynthesis' in window) {
  speechSynthesis.getVoices();
  speechSynthesis.addEventListener('voiceschanged', () => {
    speechSynthesis.getVoices();
  });
}

// Initialize
setState(StoryState.IDLE);
console.log('🤖 Peblo AI Story Buddy loaded!');
