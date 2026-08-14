import 'dart:math';
import 'package:flutter/material.dart';
import '../models/mood_model.dart';

/// A centralized service to generate dynamic mood content.
/// Built with AI-forward architecture so it can easily swap
/// local random generation with an API (like Gemini/OpenAI) in the future.
class MoodRecommendationService {
  final Random _random = Random();

  // ── 1. Motivation Messages ──

  final Map<MoodType, List<String>> _motivationMessages = {
    MoodType.happy: [
      "Your positive energy can inspire someone today.",
      "Celebrate today's happiness and carry it forward.",
      "Small happy moments create beautiful memories.",
      "A joyful heart makes everything around it brighter.",
      "Keep shining! The world needs your light today.",
      "Happiness is contagious. Let it ripple outwards.",
      "Savor this feeling, you've earned every bit of it.",
      "Your smile is your superpower today.",
      "Embrace the joy in the little things.",
      "Let today's good vibes fuel your tomorrow.",
    ],
    MoodType.sad: [
      "Not every difficult day defines your future.",
      "Take today one step at a time.",
      "Healing is never linear.",
      "It is okay to not be okay right now.",
      "Give yourself the grace to just be.",
      "Even the darkest nights eventually give way to dawn.",
      "You have survived 100% of your bad days.",
      "Be gentle with yourself today.",
      "Your feelings are valid, and it's okay to let them out.",
      "Sometimes the most productive thing you can do is rest.",
    ],
    MoodType.angry: [
      "Pause before reacting.",
      "Strength is staying calm when everything feels loud.",
      "Your peace is more valuable than your anger.",
      "Take a deep breath and let the heat dissipate.",
      "Don't let a temporary emotion cause permanent damage.",
      "Channel this intense energy into something productive.",
      "Step back. Give yourself 10 seconds of space.",
      "You control your actions, not your anger.",
      "Let go of what you cannot control.",
      "Silence is sometimes the most powerful response.",
    ],
    MoodType.stressed: [
      "You don't have to solve everything today.",
      "Breathe. Slow down. One step at a time.",
      "Rest is part of progress.",
      "Focus on the step right in front of you.",
      "You are doing your best, and that is enough.",
      "Unclench your jaw and drop your shoulders.",
      "It's just a bad day, not a bad life.",
      "Take a break before you break.",
      "Worrying won't change the outcome, but peace will.",
      "You are stronger than the pressure you feel.",
    ],
    MoodType.relaxed: [
      "Protect this peaceful mindset.",
      "Moments like these help recharge your soul.",
      "You are exactly where you need to be.",
      "Soak in the stillness.",
      "A calm mind brings inner strength.",
      "Enjoy the quiet. You deserve this.",
      "Let this tranquility wash over you.",
      "Your peace of mind is your greatest wealth.",
      "Breathe deeply and savor the present.",
      "Harmony within creates harmony without.",
    ],
    MoodType.motivated: [
      "Today's effort becomes tomorrow's success.",
      "Keep building. You're getting closer.",
      "Your potential is limitless today.",
      "Small steps every day lead to massive results.",
      "Focus on your goals and block out the noise.",
      "The only bad workout is the one that didn't happen.",
      "Turn your ambitions into actions.",
      "You have the power to create the life you want.",
      "Discipline is choosing between what you want now and what you want most.",
      "Don't stop until you're proud.",
    ],
  };

  // ── 2. Journal Prompts ──

  final Map<MoodType, List<String>> _journalPrompts = {
    MoodType.happy: [
      "What made you smile today?",
      "Who contributed to today's happiness?",
      "What memory do you want to keep?",
      "What is a small win you achieved today?",
      "List three things you are deeply grateful for right now.",
      "How can you bring this positive energy into tomorrow?",
    ],
    MoodType.sad: [
      "What happened today?",
      "What would make tomorrow slightly better?",
      "What do you need most right now?",
      "If you could talk to your younger self right now, what would you say?",
      "What is one tiny thing you can do to care for yourself tonight?",
      "Write down the hardest part of today, then draw a line through it.",
    ],
    MoodType.angry: [
      "What specifically triggered your frustration today?",
      "Is this something you will care about in 5 years?",
      "How can you communicate your boundaries better next time?",
      "What underlying emotion might be hiding behind this anger?",
      "What is one thing you can do to release this physical tension?",
      "Write a letter to the source of your anger, but do not send it.",
    ],
    MoodType.stressed: [
      "What is the single biggest source of pressure right now?",
      "What can you realistically drop or delegate today?",
      "How does your body feel when you are stressed?",
      "What is the worst-case scenario, and how would you handle it?",
      "List the things you CAN control right now.",
      "What is one relaxing thing you look forward to doing later?",
    ],
    MoodType.relaxed: [
      "What brought you this sense of peace today?",
      "How can you create more moments like this in your week?",
      "What is your favorite way to unwind?",
      "Describe the environment around you right now.",
      "What does 'balance' look like for you in this season of life?",
      "Write down a mantra that captures this calm feeling.",
    ],
    MoodType.motivated: [
      "What's your next goal?",
      "What challenge excites you today?",
      "What progress are you proud of?",
      "What is one distraction you need to eliminate?",
      "If you knew you couldn't fail, what would you start today?",
      "What is the 'why' driving your current ambitions?",
    ],
  };

  // ── 3. Quotes ──

  final Map<MoodType, List<Map<String, String>>> _quotes = {
    MoodType.happy: [
      {"quote": "Happiness is not something ready made. It comes from your own actions.", "author": "Dalai Lama"},
      {"quote": "For every minute you are angry you lose sixty seconds of happiness.", "author": "Ralph Waldo Emerson"},
      {"quote": "The most wasted of all days is one without laughter.", "author": "E.E. Cummings"},
      {"quote": "Count your age by friends, not years. Count your life by smiles, not tears.", "author": "John Lennon"},
      {"quote": "Happiness depends upon ourselves.", "author": "Aristotle"},
      {"quote": "Let us be grateful to the people who make us happy; they are the charming gardeners who make our souls blossom.", "author": "Marcel Proust"},
      {"quote": "The only joy in the world is to begin.", "author": "Cesare Pavese"},
      {"quote": "Joy is portable; bring it with you.", "author": "Unknown"},
      {"quote": "There is no path to happiness: happiness is the path.", "author": "Buddha"},
      {"quote": "A warm smile is the universal language of kindness.", "author": "William Arthur Ward"},
    ],
    MoodType.sad: [
      {"quote": "Tears come from the heart and not from the brain.", "author": "Leonardo da Vinci"},
      {"quote": "Every human walks around with a certain kind of sadness. They may not wear it on their sleeves, but it's there if you look deep.", "author": "Taraji P. Henson"},
      {"quote": "Experiencing sadness and anger can make you feel more creative, and by being creative, you can get beyond your pain or negativity.", "author": "Yoko Ono"},
      {"quote": "There are moments when I wish I could roll back the clock and take all the sadness away, but I have the feeling that if I did, the joy would be gone as well.", "author": "Nicholas Sparks"},
      {"quote": "Don't grieve. Anything you lose comes round in another form.", "author": "Rumi"},
      {"quote": "Out of suffering have emerged the strongest souls; the most massive characters are seared with scars.", "author": "Khalil Gibran"},
      {"quote": "The word 'happy' would lose its meaning if it were not balanced by sadness.", "author": "Carl Jung"},
      {"quote": "We must understand that sadness is an ocean, and sometimes we drown, while other days we are forced to swim.", "author": "R.M. Drake"},
      {"quote": "Heavy hearts, like heavy clouds in the sky, are best relieved by the letting of a little water.", "author": "Christopher Morley"},
      {"quote": "Sadness flies away on the wings of time.", "author": "Jean de La Fontaine"},
    ],
    MoodType.angry: [
      {"quote": "Holding onto anger is like grasping a hot coal with the intent of throwing it at someone else; you are the one who gets burned.", "author": "Buddha"},
      {"quote": "Speak when you are angry and you will make the best speech you will ever regret.", "author": "Ambrose Bierce"},
      {"quote": "Anger is an acid that can do more harm to the vessel in which it is stored than to anything on which it is poured.", "author": "Mark Twain"},
      {"quote": "For every minute you remain angry, you give up sixty seconds of peace of mind.", "author": "Ralph Waldo Emerson"},
      {"quote": "Anybody can become angry - that is easy, but to be angry with the right person and to the right degree and at the right time and for the right purpose, and in the right way - that is not within everybody's power and is not easy.", "author": "Aristotle"},
      {"quote": "He who angers you conquers you.", "author": "Elizabeth Kenny"},
      {"quote": "Anger makes you smaller, while forgiveness forces you to grow beyond what you are.", "author": "Cherie Carter-Scott"},
      {"quote": "The best fighter is never angry.", "author": "Lao Tzu"},
      {"quote": "Bitterness is like cancer. It eats upon the host. But anger is like fire. It burns it all clean.", "author": "Maya Angelou"},
      {"quote": "Where there is anger, there is always pain underneath.", "author": "Eckhart Tolle"},
    ],
    MoodType.stressed: [
      {"quote": "Breath is the bridge which connects life to consciousness, which unites your body to your thoughts.", "author": "Thích Nhất Hạnh"},
      {"quote": "You don't have to control your thoughts. You just have to stop letting them control you.", "author": "Dan Millman"},
      {"quote": "Almost everything will work again if you unplug it for a few minutes, including you.", "author": "Anne Lamott"},
      {"quote": "Rule number one is, don't sweat the small stuff. Rule number two is, it's all small stuff.", "author": "Robert Eliot"},
      {"quote": "Within you, there is a stillness and a sanctuary to which you can retreat at any time and be yourself.", "author": "Hermann Hesse"},
      {"quote": "The greatest weapon against stress is our ability to choose one thought over another.", "author": "William James"},
      {"quote": "Tension is who you think you should be. Relaxation is who you are.", "author": "Chinese Proverb"},
      {"quote": "Don't let your mind bully your body into believing it must carry the burden of its worries.", "author": "Astrid Alauda"},
      {"quote": "Sometimes the most productive thing you can do is relax.", "author": "Mark Black"},
      {"quote": "Calmness is the cradle of power.", "author": "Josiah Gilbert Holland"},
    ],
    MoodType.relaxed: [
      {"quote": "Smile, breathe and go slowly.", "author": "Thich Nhat Hanh"},
      {"quote": "Peace is the result of retraining your mind to process life as it is, rather than as you think it should be.", "author": "Wayne W. Dyer"},
      {"quote": "There is a calmness to a life lived in gratitude, a quiet joy.", "author": "Ralph H. Blum"},
      {"quote": "Nothing can bring you peace but yourself.", "author": "Ralph Waldo Emerson"},
      {"quote": "Quiet the mind, and the soul will speak.", "author": "Ma Jaya Sati Bhagavati"},
      {"quote": "A calm and modest life brings more happiness than the pursuit of success combined with constant restlessness.", "author": "Albert Einstein"},
      {"quote": "Peace begins with a smile.", "author": "Mother Teresa"},
      {"quote": "Your calm mind is the ultimate weapon against your challenges.", "author": "Bryant McGill"},
      {"quote": "Relaxation means releasing all concern and tension and letting the natural order of life flow through one's being.", "author": "Donald Curtis"},
      {"quote": "The mind is like water. When it's turbulent, it's difficult to see. When it's calm, everything becomes clear.", "author": "Prasad Mahes"},
    ],
    MoodType.motivated: [
      {"quote": "The secret of getting ahead is getting started.", "author": "Mark Twain"},
      {"quote": "Don't watch the clock; do what it does. Keep going.", "author": "Sam Levenson"},
      {"quote": "It always seems impossible until it's done.", "author": "Nelson Mandela"},
      {"quote": "The future belongs to those who believe in the beauty of their dreams.", "author": "Eleanor Roosevelt"},
      {"quote": "You are never too old to set another goal or to dream a new dream.", "author": "C.S. Lewis"},
      {"quote": "What you get by achieving your goals is not as important as what you become by achieving your goals.", "author": "Zig Ziglar"},
      {"quote": "Act as if what you do makes a difference. It does.", "author": "William James"},
      {"quote": "Believe you can and you're halfway there.", "author": "Theodore Roosevelt"},
      {"quote": "Everything you've ever wanted is on the other side of fear.", "author": "George Addair"},
      {"quote": "Success is not final, failure is not fatal: it is the courage to continue that counts.", "author": "Winston Churchill"},
    ],
  };

  // ── 4. Activities ──
  // Icon name strings to easily map to Material Icons dynamically

  final Map<MoodType, List<Map<String, dynamic>>> _activities = {
    MoodType.happy: [
      {"name": "Share your joy", "desc": "Text someone you care about.", "icon": Icons.favorite_rounded},
      {"name": "Do something kind", "desc": "Small acts make big ripples.", "icon": Icons.volunteer_activism_rounded},
      {"name": "Dance to a song", "desc": "Let loose and enjoy the moment.", "icon": Icons.music_note_rounded},
      {"name": "Capture the memory", "desc": "Take a photo of today.", "icon": Icons.camera_alt_rounded},
      {"name": "Celebrate a win", "desc": "Treat yourself to something small.", "icon": Icons.celebration_rounded},
      {"name": "Start a new project", "desc": "Channel positive energy into creation.", "icon": Icons.lightbulb_rounded},
    ],
    MoodType.sad: [
      {"name": "Listen to Music", "desc": "Find comfort in melodies.", "icon": Icons.headphones_rounded},
      {"name": "Talk to a Friend", "desc": "Don't carry it all alone.", "icon": Icons.forum_rounded},
      {"name": "Cozy Up", "desc": "Get under a warm blanket.", "icon": Icons.bed_rounded},
      {"name": "Take a short walk", "desc": "Fresh air can shift perspective.", "icon": Icons.directions_walk_rounded},
      {"name": "Watch a comfort movie", "desc": "Familiarity brings warmth.", "icon": Icons.movie_creation_rounded},
      {"name": "Have a warm drink", "desc": "Tea or hot cocoa helps soothe.", "icon": Icons.coffee_rounded},
    ],
    MoodType.angry: [
      {"name": "Physical Exercise", "desc": "Channel energy into a workout.", "icon": Icons.fitness_center_rounded},
      {"name": "Scream into a Pillow", "desc": "Physically release vocal tension.", "icon": Icons.record_voice_over_rounded},
      {"name": "Cold Water Splash", "desc": "Reset your nervous response.", "icon": Icons.water_drop_rounded},
      {"name": "Tear up paper", "desc": "A safe physical release.", "icon": Icons.delete_rounded},
      {"name": "Write and destroy", "desc": "Write your angry thoughts, then bin them.", "icon": Icons.edit_off_rounded},
      {"name": "Listen to heavy music", "desc": "Let the music express your anger.", "icon": Icons.speaker_rounded},
    ],
    MoodType.stressed: [
      {"name": "Take a 5-minute walk", "desc": "Step away from the stressor.", "icon": Icons.directions_walk_rounded},
      {"name": "Drink water", "desc": "Hydration grounds the body.", "icon": Icons.water_drop_rounded},
      {"name": "Brain dump", "desc": "Write everything bothering you.", "icon": Icons.edit_note_rounded},
      {"name": "Do a breathing exercise", "desc": "4-7-8 breathing technique.", "icon": Icons.air_rounded},
      {"name": "Disconnect", "desc": "Turn off notifications for 1 hour.", "icon": Icons.phonelink_erase_rounded},
      {"name": "Stretch your neck", "desc": "Release held physical tension.", "icon": Icons.accessibility_new_rounded},
    ],
    MoodType.relaxed: [
      {"name": "Guided Meditation", "desc": "10 min • Breath focus", "icon": Icons.self_improvement_rounded},
      {"name": "Nature Walk", "desc": "Observe the world around you.", "icon": Icons.park_rounded},
      {"name": "Light Stretching", "desc": "5 min • Body scan", "icon": Icons.accessibility_new_rounded},
      {"name": "Read a book", "desc": "Escape into another world.", "icon": Icons.menu_book_rounded},
      {"name": "Listen to a podcast", "desc": "Learn something new gently.", "icon": Icons.podcasts_rounded},
      {"name": "Watch the sunset", "desc": "Appreciate the slow beauty.", "icon": Icons.wb_twilight_rounded},
    ],
    MoodType.motivated: [
      {"name": "Set 3 Goals", "desc": "Break down your ambition.", "icon": Icons.checklist_rounded},
      {"name": "Clear Your Desk", "desc": "Clear space, clear mind.", "icon": Icons.cleaning_services_rounded},
      {"name": "Start the Hardest Task", "desc": "Tackle the frog first.", "icon": Icons.bolt_rounded},
      {"name": "Read for 20 minutes", "desc": "Invest in your knowledge.", "icon": Icons.menu_book_rounded},
      {"name": "Plan your week", "desc": "Map out your success trajectory.", "icon": Icons.calendar_month_rounded},
      {"name": "Update your resume", "desc": "Record your recent wins.", "icon": Icons.work_rounded},
    ],
  };

  // ── 5. Music Recommendations ──
  
  final Map<MoodType, List<Map<String, String>>> _music = {
    MoodType.happy: [
      {"title": "Happy", "artist": "Pharrell Williams"},
      {"title": "Walking on Sunshine", "artist": "Katrina & The Waves"},
      {"title": "Good Vibrations", "artist": "The Beach Boys"},
      {"title": "Uptown Funk", "artist": "Mark Ronson ft. Bruno Mars"},
      {"title": "Can't Stop the Feeling!", "artist": "Justin Timberlake"},
      {"title": "Best Day Of My Life", "artist": "American Authors"},
      {"title": "On Top Of The World", "artist": "Imagine Dragons"},
      {"title": "Good Life", "artist": "OneRepublic"},
      {"title": "September", "artist": "Earth, Wind & Fire"},
      {"title": "I Gotta Feeling", "artist": "Black Eyed Peas"},
    ],
    MoodType.sad: [
      {"title": "Let Her Go", "artist": "Passenger"},
      {"title": "Someone Like You", "artist": "Adele"},
      {"title": "Fix You", "artist": "Coldplay"},
      {"title": "All I Want", "artist": "Kodaline"},
      {"title": "Say Something", "artist": "A Great Big World"},
      {"title": "Breathe Me", "artist": "Sia"},
      {"title": "Skinny Love", "artist": "Bon Iver"},
      {"title": "The Night We Met", "artist": "Lord Huron"},
      {"title": "Chasing Cars", "artist": "Snow Patrol"},
      {"title": "Stay With Me", "artist": "Sam Smith"},
    ],
    MoodType.angry: [
      {"title": "Killing In The Name", "artist": "Rage Against The Machine"},
      {"title": "Duality", "artist": "Slipknot"},
      {"title": "Break Stuff", "artist": "Limp Bizkit"},
      {"title": "Chop Suey!", "artist": "System Of A Down"},
      {"title": "Given Up", "artist": "Linkin Park"},
      {"title": "Walk", "artist": "Pantera"},
      {"title": "Before I Forget", "artist": "Slipknot"},
      {"title": "In the End", "artist": "Linkin Park"},
      {"title": "Bodies", "artist": "Drowning Pool"},
      {"title": "Enter Sandman", "artist": "Metallica"},
    ],
    MoodType.stressed: [
      {"title": "Weightless", "artist": "Marconi Union"},
      {"title": "River Flows In You", "artist": "Yiruma"},
      {"title": "Deep Focus", "artist": "Spotify Chill"},
      {"title": "Rain Sounds", "artist": "Nature Ambience"},
      {"title": "Clair de Lune", "artist": "Claude Debussy"},
      {"title": "Spiegel im Spiegel", "artist": "Arvo Pärt"},
      {"title": "Airstream", "artist": "Electra"},
      {"title": "Mellomaniac (Chill Out Mix)", "artist": "DJ Shah"},
      {"title": "Gymnopédie No.1", "artist": "Erik Satie"},
      {"title": "Binaural Beats Focus", "artist": "Therapy"},
    ],
    MoodType.relaxed: [
      {"title": "Lofi Hip Hop Radio", "artist": "ChilledCow"},
      {"title": "Sunset Lover", "artist": "Petit Biscuit"},
      {"title": "Forest Rain", "artist": "45 min ambient"},
      {"title": "Ocean Tides", "artist": "60 min ambient"},
      {"title": "Soft Crackle", "artist": "30 min ASMR"},
      {"title": "To Build A Home", "artist": "The Cinematic Orchestra"},
      {"title": "Holocene", "artist": "Bon Iver"},
      {"title": "Midnight City", "artist": "M83"},
      {"title": "Teardrop", "artist": "Massive Attack"},
      {"title": "Weightless (Ambient)", "artist": "Marconi Union"},
    ],
    MoodType.motivated: [
      {"title": "Believer", "artist": "Imagine Dragons"},
      {"title": "Hall of Fame", "artist": "The Script"},
      {"title": "Legends Never Die", "artist": "Against The Current"},
      {"title": "Eye of the Tiger", "artist": "Survivor"},
      {"title": "Lose Yourself", "artist": "Eminem"},
      {"title": "Stronger", "artist": "Kanye West"},
      {"title": "Remember The Name", "artist": "Fort Minor"},
      {"title": "Till I Collapse", "artist": "Eminem"},
      {"title": "Unstoppable", "artist": "Sia"},
      {"title": "Can't Hold Us", "artist": "Macklemore & Ryan Lewis"},
    ],
  };

  // ── Public API (Simulates async AI fetching for future compat) ──

  /// Fetches a dynamic motivation message
  Future<String> getMotivationMessage(MoodType mood) async {
    final list = _motivationMessages[mood] ?? _motivationMessages[MoodType.happy]!;
    return list[_random.nextInt(list.length)];
  }

  /// Fetches a dynamic journal prompt
  Future<String> getJournalPrompt(MoodType mood) async {
    final list = _journalPrompts[mood] ?? _journalPrompts[MoodType.happy]!;
    return list[_random.nextInt(list.length)];
  }

  /// Fetches N random quotes without duplication
  Future<List<Map<String, String>>> getQuotes(MoodType mood, {int count = 3}) async {
    final list = List<Map<String, String>>.from(_quotes[mood] ?? _quotes[MoodType.happy]!);
    list.shuffle(_random);
    return list.take(count).toList();
  }

  /// Fetches N random activities without duplication
  Future<List<Map<String, dynamic>>> getActivities(MoodType mood, {int count = 3}) async {
    final list = List<Map<String, dynamic>>.from(_activities[mood] ?? _activities[MoodType.happy]!);
    list.shuffle(_random);
    return list.take(count).toList();
  }

  /// Fetches N random music tracks without duplication
  Future<List<Map<String, String>>> getMusicRecommendations(MoodType mood, {int count = 3}) async {
    final list = List<Map<String, String>>.from(_music[mood] ?? _music[MoodType.happy]!);
    list.shuffle(_random);
    return list.take(count).toList();
  }
}
