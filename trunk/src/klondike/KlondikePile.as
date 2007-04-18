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

import as3cards.core.CardValue;
import as3cards.core.Suit;
import as3cards.visual.CardPile;
import as3cards.visual.SpreadingDirection;
import as3cards.visual.VisualCard;	

/**
 * A KlondikePile is the classic card pile for the Klondike
 * game - only accept the card if it's one less in value and
 * it has the opposite suit color (i.e. 7 of hearts can be 
 * added to 8 of spades).
 * 
 * KlondikePiles can contain N number of "face down cards"
 * underneath the face up cards, as necessary.  The face down
 * cards can only be added to the pile when the Klondike game
 * is initially dealt.
 */
public class KlondikePile extends CardPile {
	
	/**
	 * Constructor
	 */
	public function KlondikePile()
	{
		super( null, SpreadingDirection.SOUTH );
	}
	
	/**
	 * Determines if the card pile can be added to this klondike pile.
	 */
	public override function canAdd( cardPile:CardPile ):Boolean
	{
		// Get the top card from the pile and the card attempting to be added
		var topCard:VisualCard = getChildAt( numChildren - 1 ) as VisualCard;
		var cardToAdd:VisualCard = cardPile.getChildAt( 0 ) as VisualCard;
		
		// TODO: if the cardPile passed in it not a KlondikePile, we shouldn't
		// allow the add
		
		// Only allow the add if the top card of the pile is face up and the
		// the card being added has the opposite color suit
		if ( !topCard.isDown && Suit.isRed( topCard.card.suit ) != Suit.isRed( cardToAdd.card.suit ) )
		{
			// Make sure that the card being added has the next sequential value
			if ( topCard.card.value == cardToAdd.card.value + 1 )
			{
				return true;
			} 
			// Check for special case of adding 2 to ace
			else if ( topCard.card.value == CardValue.TWO && cardToAdd.card.value == CardValue.ACE )
			{
				return true;
			}
		}
		
		return false;
	}
	
} // end class
} // end package