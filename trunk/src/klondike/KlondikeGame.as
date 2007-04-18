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
	
import as3cards.core.DeckType;
import as3cards.visual.CardPile;
import as3cards.visual.SkinManager;
import as3cards.visual.SpreadingDirection;
import as3cards.visual.VisualCard;
import as3cards.visual.VisualDeck;

import flash.display.Sprite;
import flash.events.MouseEvent;
import flash.display.DisplayObject;
import flash.geom.Point;
	
/**
 * 
 */
public class KlondikeGame extends Sprite
{
	private var visualDeck:VisualDeck;
	private var dealtPile:CardPile;		// could be DealOnePile or DealThreePile
	private var klondikePiles:Array;
	private var acePiles:Array;
	
	// For drag and drop support
	private var draggingPile:CardPile;
	private var originatingPile:CardPile;
	
	/**
	 * Constructor
	 */
	public function KlondikeGame()
	{
		newGame();
		
		addEventListener( MouseEvent.MOUSE_UP, checkDrop );
	}
	
	/**
	 * Constructs a new game of Klondike
	 */
	public function newGame():void
	{
		cleanUp();
		createBoard();
		dealCards();
		setupListeners();
	}
	
	/**
	 * Removes all of visual elements so that they can be
	 * garbage collected, and gives us a "clean slate" to 
	 * create the game board
	 */
	private function cleanUp():void
	{
		while ( numChildren > 0 )
		{
			removeChildAt( 0 );
		}
	}
	
	/**
	 * Creates the initial layout for the game, sets up the
	 * card piles but does not deal.
	 */
	private function createBoard():void
	{
		// TODO: Get board dimensions from a style manager?
		visualDeck = new VisualDeck( DeckType.WITHOUT_JOKERS );
		visualDeck.x = 0;
		visualDeck.y = 0;
		addChild( visualDeck );
		
		
		// TODO: Use a factory to get the dealtPile based on the
		// user's deal settings (deal one vs. deal three)
		dealtPile = new DealOnePile();
		dealtPile.x = 90;
		dealtPile.y = 0;
		addChild( dealtPile );
		
		// Store references to the Klondike piles
		klondikePiles = new Array();
		var curX:int = 0;
		var curY:int = 100;
		// There are 7 Klondike piles to create
		for ( var i:int = 0; i < 7; i++ )
		{
			var kp:KlondikePile = new KlondikePile();
			kp.x = curX;
			kp.y = curY;
			// Saves the reference
			klondikePiles.push( kp );
			// Add the pile to the screen
			addChild( kp );
			// Move the next pile 90 to the right
			curX += 90;
		}
		
		acePiles = new Array();
		curX = 90*3;
		curY = 0;
		// There are 4 Ace piles to create
		for ( i = 0; i < 4; i++ )
		{
			var ap:AcePile = new AcePile();
			ap.x = curX;
			ap.y = curY;
			// Save the reference
			acePiles.push( ap );
			// Add the pile to the screen
			addChild( ap );
			// Move the next pile 90 to the right
			curX += 90;
		}
	}
	
	/**
	 * Deals the cards from the deck into the klondike piles
	 */
	private function dealCards():void
	{
		// First, shuffle the deck
		visualDeck.shuffle();
		
		// Deal rows horizontally
		for ( var i:int = 0; i < 7; i++ )
		{
			// Flip over the first card, deal the rest face down
			var card:VisualCard = new VisualCard( visualDeck.deal(), false );
			// Set up the card for drag and drop
			configureDrag( card );
			// Add the card to the pile
			klondikePiles[i].addCard( card );
						
			// Add face down cards to all of the card piles on the right of this one
			for ( var j:int = i + 1; j < 7; j++ )
			{
				klondikePiles[j].addCard( new VisualCard( visualDeck.deal(), true ) );
			}
		}
	}
	
	/**
	 * Configure the event listeners for the game
	 */
	private function setupListeners():void
	{
		// Whenever the deck is clicked, we need to deal
		visualDeck.addEventListener( MouseEvent.CLICK, deckClick );
		// ButtonMode gives us the hand cursor
		visualDeck.buttonMode = true;
	}
	
	/**
	 * Event handler - the deck was clicked, determine if we
	 * can deal.
	 */
	private function deckClick( event:MouseEvent ):void
	{
		// TODO: Check if can cycle based on game rules / scoring
		if ( visualDeck.isEmpty() )
		{
			// Bring the deal cards back into the deck to deal them again
			visualDeck.reset();
			// Remove everything from the dealtPile
			while ( dealtPile.numChildren != 0 )
			{
				dealtPile.removeChildAt( 0 );
			}
			// Require two clicks to deal a card when the deck is empty - the
			// first click just resets the deck, and we return here so that
			// another click is required to deal
			return;
		}
		
		// Remove the event listener for the previous card on the dealt pile
		// so that the user can only pick up the "top card" on the dealtPile.
		// This doens't matter in the draw-one style, so maybe we run a
		// conditional here to test that to avoid overhead of removeing listeners
		// when we don't need to.
		if ( dealtPile.numChildren > 0 )
		{
			// TODO: Really, we should do this for the last X amount of cards dealt?
			configureDrag( dealtPile.getChildAt( 0 ) as VisualCard, false );
		}
		
		// Deal a card onto the dealt pile, pass in false because we don't want
		// to remove the card from the deck yet (since it's not moved to a klondike
		// or ace pile just yet).
		var card:VisualCard = new VisualCard( visualDeck.deal( false ), false );
					
		// Add the card to the dealt pile
		dealtPile.addCard( card );
		
		// Only add the event listener for the top-card.  We do things this way
		// so that if we go to deal-3 style where more than one card is visible,
		// only clicking the top card actually does something
		configureDrag( card );
	}
	
	/**
	 * Configures a card for drag and drop behavior.
	 */
	public function configureDrag( card:VisualCard, canDrag:Boolean = true ):void
	{
		// Do we add the event listeners or remove them?
		if ( canDrag )
		{
			card.addEventListener( MouseEvent.MOUSE_DOWN, checkDragStart );
			card.buttonMode = true;
		}
		else
		{
			card.removeEventListener( MouseEvent.MOUSE_DOWN, checkDragStart );
			card.buttonMode = false;
		}
	}
	
	/** 
	 * Update the state of a card pile - either turn it into a King
	 * pile, make the "new topmost card" draggable (cardPiles and dealtPile), 
	 * or in the special case that an ace was drug off an ace pile, we need to
	 * put it's empty skin back, so we can probably just call update skin
	 */
	public function updatePileState( cardPile:CardPile ):void
	{
		// Determine what kind of pile the cardPile is
		if ( cardPile is AcePile && cardPile.numChildren == 0 )
		{
			cardPile.updateSkin();
		}
		else if ( cardPile is KlondikePile )
		{
			if ( cardPile.numChildren == 0 )
			{
				// Empty pile, turn it into a King Pile - find a reference to
				// the Klondike pile in the list of Klondike piles and replace
				// it with a King pile.
				for ( var i:int = 0; i < klondikePiles.length; i++ )
				{
					if ( klondikePiles[i] == cardPile )
					{
						var kingPile:KingPile = new KingPile();
						kingPile.x = cardPile.x;
						kingPile.y = cardPile.y;
						removeChild( cardPile );
						addChild( kingPile );
						klondikePiles[i] = kingPile;
						break;
					}
				}
			}
			else
			{
				// Make the top most card on the pile clickable (so we can turn it over)
				cardPile.getChildAt( cardPile.numChildren - 1 ).addEventListener( MouseEvent.CLICK, turnOver );
				Sprite( cardPile.getChildAt( cardPile.numChildren - 1 ) ).buttonMode = true;
			}
		}
		else
		{
			// cardPile is a dealt pile
			if ( cardPile.numChildren )
			{
				configureDrag( cardPile.getChildAt( cardPile.numChildren - 1 ) as VisualCard );
			}
		}
	}
	
	/**
	 * Turns the card that was clicked on over (so its face up).  This is
	 * used when a Klondike pile contains only face down cards - the last card
	 * in the pile can be turned over.
	 */
	public function turnOver( event:MouseEvent ):void
	{
		// Use currentTarget because sometimes the target is a Loader depending
		// on how the skin is implemented
		var card:VisualCard = VisualCard( event.currentTarget );
		// Set the card face up
		card.isDown = false;
		// Set up the card for drag and drop
		configureDrag( card );
		// It's already turned over, remove the listener
		card.removeEventListener( MouseEvent.CLICK, turnOver );
	}
	
	/**
	 * Should be called after every move to update the status of the game.
	 */
	public function updateGameStatus():void
	{
		// TODO: Check for win game
		
		// TODO: Check for no more moves
		
		// TODO: Automatically make moves?
	}
	
	/**
	 * Called when the mouse is released - if there a pile currently
	 * being dragged around, check to see if we can play the pile, otherwise
	 * we need to move it back to where it came from.
	 */
	public function checkDrop( event:MouseEvent ):void
	{
		// Only check the drop if we were actually dragging something
		if ( draggingPile == null ) return;
		
		// Can the pile be played?
		if ( !playPile( event ) )
		{
			// Can't be played - move it back to where it came from.
			moveBack( event );
		}
	}
	
	/**
	 * Returns true if the dragging pile could be added to the target pile,
	 * and false otherwise.
	 */
	public function playPile( event:MouseEvent ):Boolean
	{
		// Get a list of everything underneath the mouse cursor
		var dropObjs:Array = stage.getObjectsUnderPoint( new Point( event.stageX, event.stageY ) );
	
		// If there is only one object under the point, that means the user
		// just dropped the dragging pile on the stage, so don't bother trying
		// to play the pile
		if ( dropObjs.length == 0 ) return false;
		
		// The object at the second to last location in the array will be the one "just under" the dragging poile
		// and therefore the drop target.  Loop over it's parent's until we get the cardPile it's a part of.
		// Note: Deal with ace pile and empty king piles - there is no visual card in the parent chain, so we'll
		// test for is CardPile instead.
		// Note: Also deal with dropping on VisualDeck since no VisualCard or CardPile in that parent chain
		var target:DisplayObject = dropObjs[ dropObjs.length - 2 ];
		// Keep going through parents until we get a VisualCard, a KlondikePile, or an AcePile
		while (!( target is VisualCard || target is KlondikePile || target is AcePile ))
		{
			// Deal with drop on VisualDeck
			if ( target == null ) return false;
	
			// Move up the chain
			target = target.parent;
		}
		
		var cardPile:CardPile;
		
		// When we drop on a card, get the card pile the card was dropped on
		if ( target is VisualCard )
		{
			cardPile = target.parent as CardPile;
			
			// Check to make sure that the top card in the pile was actually 
			// in the drop list.  This stops the user from adding to a pile without
			// dropping on the top most card in that pile
			if ( target != cardPile.getChildAt( cardPile.numChildren - 1 ) )
			{
				return false;
			}
		}
		else
		{
			// Dropped on an empty ace or king pile
			cardPile = target as CardPile;
		}
		
		// Check to see if we can add the dragging pile to the drop target
		if ( cardPile.canAdd( draggingPile ) )
		{
			// Special case - remove the card from the deck
			// if the originating pile is the dealt pile
			if ( originatingPile == dealtPile )
			{
				visualDeck.remove( VisualCard( draggingPile.getChildAt( draggingPile.numChildren - 1 ) ).card );
				
				// Check to see if this was the last card we removed from the
				// deck, and if so make sure the dealtPile has the
				// deck no cycle skin and isn't clickable anymore.
				if ( dealtPile.numChildren == 0 && visualDeck.isEmpty() )
				{
					visualDeck.canCycle = false;
					visualDeck.updateSkin();
					visualDeck.removeEventListener( MouseEvent.CLICK, deckClick );
					visualDeck.buttonMode = false;
				}
				
			}
			// Add the dragging pile to the new card pile
			cardPile.addPile( draggingPile );
			
			// Update the originating pile state
			updatePileState( originatingPile );
			
			// Done with the drag operation, clear the variables
			originatingPile = null;
			draggingPile = null;
			
			// Succesfully played the pile
			return true;
		}
		
		// Couldn't play the pile
		return false;
	}
	
	/**
	 * Moves the dragging pile back to where it came from
	 */
	private function moveBack( event:MouseEvent ):void
	{
		// Stop dragging
		//draggingPile.drop();
		draggingPile.stopDrag();
		
		// Merge the piles back
		originatingPile.addPile( draggingPile );
		
		// Done with the drag operation, clear the variables
		draggingPile = null;
		originatingPile = null;
	}
	
	/**
	 * A click + mouse move is a drag start, a click + release isn't.
	 */
	private function checkDragStart( event:MouseEvent ):void
	{
		event.target.addEventListener( MouseEvent.MOUSE_MOVE, dragStart );
		event.target.addEventListener( MouseEvent.MOUSE_UP, cancelCheckDragStart );
	}
	
	/**
	 * Remove the drag start listener since the click wasn't a drag.
	 */
	private function cancelCheckDragStart( event:MouseEvent ):void
	{
		event.target.removeEventListener( MouseEvent.MOUSE_MOVE, dragStart );
		event.target.removeEventListener( MouseEvent.MOUSE_UP, cancelCheckDragStart );
	}
	
	/**
	 * Start dragging a card pile
	 */
	public function dragStart( event:MouseEvent ):void
	{
		// Remove the drag start listeners
		event.target.removeEventListener( MouseEvent.MOUSE_MOVE, dragStart );
		event.target.removeEventListener( MouseEvent.MOUSE_UP, cancelCheckDragStart );
		
		// The event target is the skin, so it's parent is the visual card
		// and then the parent of that is the cardpile.
		var card:VisualCard = event.target.parent.parent as VisualCard;
		originatingPile = card.parent as CardPile;
		
		// Save the location of the card, so we can set the pile that it returned to that same
		// location when we re-parent to the root.  This makes the reparent seemless as there is
		// no visual change to the card's location.
		var pt:Point = new Point( originatingPile.x + card.x, originatingPile.y + card.y);
		if ( originatingPile is AcePile )
		{
			// Only remove the top card on ace piles
			draggingPile = originatingPile.removeCard( card, false );
		}
		else
		{
			// Remove the card being dragged and all of the cards below it in the pile - create
			// a new pile that spreads south
			draggingPile = originatingPile.removeCard( card, true, SpreadingDirection.SOUTH );
		}
		
		// Reset the position of the draggingPile to the old location of the picked up card
		draggingPile.x = pt.x;
		draggingPile.y = pt.y;
		// Add the dragging pile on top of everything in the main display list
		addChild( draggingPile );
		
		// TODO: figure out the correct drag bounds, use localToGlobal probably
		//draggingPile.drag( /*true, new Rectangle(-1000, -1000, 1000, 1000)*/ );
		draggingPile.startDrag();
		
		// Add the filters to the dragging pile
		draggingPile.filters = SkinManager.skinCreator.dragFilters;
	}

} // end class
} // end package