const drinkService = require('../services/drinkService');

async function listAdminDrinks(req, res) {
  try {
    const drinks = await drinkService.listAdminDrinks();
    res.json({ success: true, drinks });
  } catch (err) {
    console.error('[drinkController] listAdminDrinks error', err);
    res.status(500).json({ error: 'Failed to load drinks' });
  }
}

async function getDrinkDetails(req, res) {
  try {
    const drinkId = parseInt(req.params.id, 10);
    if (!drinkId) return res.status(400).json({ error: 'Invalid drink id' });
    const drink = await drinkService.getDrinkDetail(drinkId, req.admin?.admin_id);
    if (!drink) {
      return res.status(404).json({ error: 'Drink not found' });
    }
    res.json({ success: true, drink });
  } catch (err) {
    console.error('[drinkController] getDrinkDetails error', err);
    res.status(500).json({ error: 'Failed to load drink details' });
  }
}

async function upsertDrink(req, res) {
  try {
    const drink = await drinkService.upsertDrink(req.body || {}, req.admin?.admin_id);
    res.json({ success: true, drink });
  } catch (err) {
    console.error('[drinkController] upsertDrink error', err);
    res.status(400).json({ error: err.message || 'Failed to save drink' });
  }
}

async function deleteDrink(req, res) {
  try {
    await drinkService.deleteDrink(req.params.id);
    res.json({ success: true });
  } catch (err) {
    console.error('[drinkController] deleteDrink error', err);
    res.status(500).json({ error: 'Failed to delete drink' });
  }
}

module.exports = {
  listAdminDrinks,
  getDrinkDetails,
  upsertDrink,
  deleteDrink,
};

