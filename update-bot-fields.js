const fs = require('fs');
const path = require('path');

// Authoritative list of updates (id, price, estimatedSuccessRate, winRate)
const updates = [
  { id: 'even-odd-martingale-v1-1', price: 1250, estimatedSuccessRate: 89, winRate: '55-65%' },
  { id: 'recovery-bot-v8-0', price: 1950, estimatedSuccessRate: 90, winRate: '60-70%' },
  { id: 'rise-fall-candle-trader-v2-0', price: 1200, estimatedSuccessRate: 89, winRate: '60-70%' },
  { id: 'smart-rise-fall-trader-v2-0', price: 2300, estimatedSuccessRate: 90, winRate: '62-72%' },
  { id: 'tesla-rise-fall-trader-v1-0', price: 2000, estimatedSuccessRate: 89, winRate: '65-75%' },
  { id: 'triple-split-martingale-v2-0', price: 2200, estimatedSuccessRate: 90, winRate: '55-65%' },
  { id: 'under-9-basic-trader-v1-0', price: 2050, estimatedSuccessRate: 89, winRate: '60-70%' },
  { id: 'under-9-touch-trader-v2-0', price: 2100, estimatedSuccessRate: 89, winRate: '60-70%' },
  { id: 'digits-matches-differs-list-analyser-strategy', price: 2700, estimatedSuccessRate: 92, winRate: '65-75%' },
  { id: 'profit-bot-v2-0', price: 1900, estimatedSuccessRate: 90, winRate: '60-70%' },
  { id: 'premium-digit-differ-v2-0', price: 2100, estimatedSuccessRate: 90, winRate: '60-70%' },
  { id: 'even-odd-martingale-v1-0', price: 2150, estimatedSuccessRate: 88, winRate: '60-75%' },
  { id: 'even-odd-double-recovery-v2-0', price: 2200, estimatedSuccessRate: 89, winRate: '60-70%' },
  { id: 'even-odd-direction-keeper-v3-0', price: 2250, estimatedSuccessRate: 89, winRate: '60-75%' },
  { id: 'consecutive-digits-trader-v2-0', price: 2300, estimatedSuccessRate: 88, winRate: '60-70%' },
  { id: 'consecutive-digits-differ-v1-0', price: 2350, estimatedSuccessRate: 88, winRate: '60-75%' },
  { id: 'digits-analyzer-pro-v3-0', price: 2400, estimatedSuccessRate: 89, winRate: '60-80%' },
  { id: 'dual-split-martingale-v1-0', price: 2450, estimatedSuccessRate: 88, winRate: '60-70%' },
  { id: 'double-above-analyzer-v3-0', price: 2500, estimatedSuccessRate: 88, winRate: '65-85%' },
  { id: 'digit-over-3-strategy-v2-0', price: 2550, estimatedSuccessRate: 88, winRate: '60-75%' },
  { id: 'chart-analysis-trader-v2-0', price: 1150, estimatedSuccessRate: 89, winRate: '65-80%' },
  { id: 'mathews-lightning-trader-v1-0', price: 2600, estimatedSuccessRate: 89, winRate: '65-80%' },
  { id: 'last-digit-trader-v1-0', price: 2650, estimatedSuccessRate: 89, winRate: '65-80%' },
  { id: 'odd-even-basic-trader-v1-0', price: 2700, estimatedSuccessRate: 89, winRate: '60-70%' },
  { id: 'naira-printer-original-v1-0', price: 2750, estimatedSuccessRate: 89, winRate: '60-75%' },
  { id: 'even-odd-percentage-trader-v2-0', price: 2800, estimatedSuccessRate: 89, winRate: '60-75%' },
  { id: 'even-odd-pattern-trader-v1-0', price: 2850, estimatedSuccessRate: 89, winRate: '60-70%' },
  { id: 'oracle-predictor-v1-0', price: 1900, estimatedSuccessRate: 88, winRate: '50-60%' },
  { id: 'even-odd-time-analyzer-v2-0', price: 2900, estimatedSuccessRate: 90, winRate: '60-80%' },
  { id: 'even-odd-pro-analyzer-v4-0', price: 2950, estimatedSuccessRate: 90, winRate: '65-85%' },
  { id: 'even-odd-predictor-v1-0', price: 3000, estimatedSuccessRate: 89, winRate: '60-70%' },
  { id: 'master-strategy-v3-0', price: 2000, estimatedSuccessRate: 90, winRate: '70-90%' },
  { id: 'last-digit-martingale-v2-0', price: 3050, estimatedSuccessRate: 89, winRate: '60-75%' },
  { id: 'laban-strategy-v3-1', price: 3100, estimatedSuccessRate: 89, winRate: '60-80%' },
  { id: 'multiplier-strategy-v1-0', price: 3150, estimatedSuccessRate: 90, winRate: '65-80%' },
  { id: 'matrix-strategy-v2-0', price: 1950, estimatedSuccessRate: 89, winRate: '70-85%' },
  { id: 'candle-miner-v2-0', price: 3200, estimatedSuccessRate: 89, winRate: '60-75%' },
  { id: 'c4-strategy-v2-0', price: 3250, estimatedSuccessRate: 88, winRate: '60-70%' },
  { id: 'binary-profit-trader-v2-0', price: 2200, estimatedSuccessRate: 83, winRate: '45-65%' },
  { id: 'auto-c4-pro-trader-v2-0', price: 2400, estimatedSuccessRate: 86, winRate: '55-70%' },
  { id: 'ai-predictor-v2-0', price: 2400, estimatedSuccessRate: 91, winRate: '55-65%' },
  { id: 'ai-predictor-v1-0', price: 2600, estimatedSuccessRate: 89, winRate: '50-60%' },
  { id: '80-over-strategy-v1-0', price: 2700, estimatedSuccessRate: 88, winRate: '50-60%' },
  { id: '24-hour-trader-v1-0', price: 2800, estimatedSuccessRate: 87, winRate: '50-60%' },
  { id: 'profit-maker-v1-0', price: 1900, estimatedSuccessRate: 86, winRate: '50-60%' },
  { id: 'smart-bot-v1-0', price: 2800, estimatedSuccessRate: 92, winRate: '50-60%' },
  { id: 'over-under-pro-strategy-v8-0', price: 3200, estimatedSuccessRate: 94, winRate: '60-70%' },
  { id: 'over-under-pro-strategy-v8-1', price: 2600, estimatedSuccessRate: 91, winRate: '65-75%' },
  { id: 'profit-maker-v1-1', price: 1900, estimatedSuccessRate: 88, winRate: '55-65%' },
  { id: 'reverse-money-multiplier-v1-2', price: 1900, estimatedSuccessRate: 87, winRate: '50-60%' },
  { id: 'speed-trader-pro-v2-0', price: 1900, estimatedSuccessRate: 88, winRate: '60-70%' },
  { id: 'pro-digits-v5-strategy-v1-0', price: 2500, estimatedSuccessRate: 91, winRate: '65-75%' },
  { id: 'auto-c4-volt-ai-premium-robot-2-1', price: 3100, estimatedSuccessRate: 94, winRate: '70-80%' },
  { id: 'auto-c4-volt-ai-premium-robot', price: 3000, estimatedSuccessRate: 94, winRate: '70-80%' },
  { id: 'auto-c4-volt-ai-premium-robot-main', price: 2900, estimatedSuccessRate: 94, winRate: '70-80%' },
  { id: 'daily-range-grid-master-v1-0', price: 2050, estimatedSuccessRate: 90, winRate: '70-80%' },
  { id: 'pullback-grid-master-v1-0', price: 1900, estimatedSuccessRate: 89, winRate: '65-75%' },
  { id: 'ten-day-average-master-v1-0', price: 2650, estimatedSuccessRate: 96, winRate: 'N/A' },
  { id: 'session-highlight-master-v1-0', price: 2950, estimatedSuccessRate: 99, winRate: 'N/A' },
  { id: 'infinity-hedge-tp-sl-master-v1-0', price: 2350, estimatedSuccessRate: 94, winRate: '65-75%' },
  { id: 'daily-range-grid-master-v2-0', price: 2000, estimatedSuccessRate: 89, winRate: '55-65%' },
  { id: 'cyborg-money-master-v1-0', price: 1950, estimatedSuccessRate: 88, winRate: '50-60%' },
  { id: 'infinity-hedge-master-v1-0', price: 2200, estimatedSuccessRate: 92, winRate: '60-70%' },
  { id: 'fractal-breakout-master-v1-0', price: 2500, estimatedSuccessRate: 95, winRate: '70-80%' },
  { id: 'smart-network-scalper-v1-0', price: 2800, estimatedSuccessRate: 97, winRate: '75-85%' }
];

const botsPath = path.join(__dirname, 'bots.json');
const bots = JSON.parse(fs.readFileSync(botsPath, 'utf8'));

let updatedCount = 0;

for (const update of updates) {
  const bot = bots.find(b => b.id === update.id);
  if (bot) {
    let changed = false;
    if (bot.price !== update.price) {
      bot.price = update.price;
      changed = true;
    }
    if (bot.estimatedSuccessRate !== update.estimatedSuccessRate) {
      bot.estimatedSuccessRate = update.estimatedSuccessRate;
      changed = true;
    }
    if (bot.winRate !== update.winRate) {
      bot.winRate = update.winRate;
      changed = true;
    }
    if (changed) {
      console.log(`Updated bot: ${bot.name} (${bot.id})`);
      updatedCount++;
    }
  } else {
    console.warn(`Bot not found: ${update.id}`);
  }
}

fs.writeFileSync(botsPath, JSON.stringify(bots, null, 2));
console.log(`\nUpdate complete. ${updatedCount} bots updated.`); 