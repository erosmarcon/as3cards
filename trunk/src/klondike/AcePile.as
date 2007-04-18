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
import as3cards.visual.CardPile;
import as3cards.visual.SkinManager;
import as3cards.visual.VisualCard;

/**
 * An AcePile is a CardPile that only accepts the "next card"
 * in ascending order, of the same suit as the Ace.
 */
public class AcePile extends CardPile
{
	
	/**
	 * Constructor
	 */
	public function AcePile()
	{
		super( null );
		updateSkin();
	}
	
	/**
	 * Override can add so we can create custom logic to accept / reject
	 * the card pile.
	 */
	public override function canAdd( cardPile:CardPile ):Boolean
	{
		// Can only drag one card at a time to the ace pile
		if ( cardPile.numChildren > 1 )
		{
			return false;
		}
		
		// The first card must be an ace - check to see if the only thing
		// displaying is the skin at the moment.
		if ( numChildren == 1 && !( getChildAt( 0 ) is VisualCard ) )
		{
			var possibleAce:VisualCard = VisualCard( cardPile.getChildAt( 0 ) );
			if ( possibleAce.card.value == CardValue.ACE )
			{
				return true;
			}
		}
		else
		{
			// Get the top card from the pile and the card attempting to be added
			var top:VisualCard = getChildAt( numChildren - 1 ) as VisualCard;
			var nextCard:VisualCard = cardPile.getChildAt( 0 ) as VisualCard;
			
			// Check same suit
			if ( top.card.suit == nextCard.card.suit )
			{
				// Check that the next card value is directly after the current
				// top card
				if ( top.card.value == nextCard.card.value - 1 )
				{
					return true;
				}
				// Special case, check for ace and 2
				if ( top.card.value == CardValue.ACE && nextCard.card.value == CardValue.TWO )
				{
					return true;
				}
			}
		}
		
		// Reject the card pile because it doesn't meet the criteria
		return false;
	}
	
	/**
	 * Creates the visual images for the card pile
	 */
	public override function updateSkin():void
	{
		// Check to see if a skin has been created yet
		if ( numChildren == 0 )
		{
			addChild( SkinManager.skinCreator.createEmptyAce() );
		}
		else if ( numChildren == 1 && !( getChildAt( 0 ) is VisualCard ) )
		{
			// If there is only 1 child and it's not a visual card, then 
			// it must be just the skin, so we'll replace it as necessary
			removeChildAt( 0 );
			addChild( SkinManager.skinCreator.createEmptyAce() );
		}
		
		// Update the skin of all of the cards in the pile
		super.updateSkin();
	}

} // end class
} // end package