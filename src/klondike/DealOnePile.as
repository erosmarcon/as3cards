/*
 * Copyright (c) 2007 Darron Schall
 * 
 * Permission is hereby granted, free of charge, to any person obtaining a copy of
 * this software and associated documentation files (the "Software"), to deal in
 * the Software without restriction, including without limitation the rights to
 * use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies
 * of the Software, and to permit persons to whom the Software is furnished to do
 * so, subject to the following conditions:
 * 
 * The above copyright notice and this permission notice shall be included in all
 * copies or substantial portions of the Software.
 * 
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 * SOFTWARE.
 */
package klondike
{

import as3cards.visual.CardPile;
import as3cards.visual.VisualCard;
import as3cards.visual.SpreadingDirection;	

/**
 * A DealOnePile is the stack of "dealt" cards from the
 * deck.
 */
public class DealOnePile extends CardPile
{

	/**
	 * Constructor
	 */
	public function DealOnePile()
	{
		super( null, SpreadingDirection.NONE );
	}
	
	/**
	 * You can not manually add cards to the card pile
	 */
	public override function canAdd( cardPile:CardPile ):Boolean
	{
		return false;
	}
	
	/**
	 * When a card is added, the face of the card needs to be showing
	 */
	public override function addCard( card:VisualCard ):void
	{
		// Make sure the card is face up when added to the dealt pile
		card.isDown = false;
		
		super.addCard( card );
	}
	
} // end class
} // end package