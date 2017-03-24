
#include<iostream>
template<class Object>
SList<Object>::SList( ) {
  init( );
}

template<class Object>
SList<Object>::SList( const SList &rhs ) {
  init( );
  *this = rhs;                                   // then assign rhs to this.
}

template<class Object>
void SList<Object>::init( ) {
  for ( int i = 0; i < LEVEL; i++ ) {  // for each level
    // create the left most dummy nodes;
    header[i] = new SListNode<Object>;
    header[i]->prev = NULL;
    header[i]->down = ( i > 0 ) ? header[i - 1] : NULL;
    header[i]->up = NULL;

    if ( i > 0 ) header[i - 1]->up = header[i];

    // create the right most dummy nodes;
    header[i]->next = new SListNode<Object>;
    header[i]->next->next = NULL;
    header[i]->next->prev = header[i];
    header[i]->next->down = ( i > 0 ) ? header[i - 1]->next : NULL;
    header[i]->next->up = NULL;
    if ( i > 0 ) header[i - 1]->next->up = header[i]->next;
  }

  // reset cost.
  cost = 0;
}

template<class Object>
SList<Object>::~SList( ) {
  clear( );                                      // delete items starting 1st
  for ( int i = 0; i < LEVEL; i++ ) {
    delete header[i]->next;                      // delete the right most dummy
    delete header[i];                            // delete the left most dummy
  }
}

template<class Object>
bool SList<Object>::isEmpty( ) const {
  return ( header[0]->next->next == NULL );
}

template<class Object>
int SList<Object>::size( ) const {
  SListNode<Object> *p = header[0]->next; // at least the right most dummy
  int size = 0;

  for ( ; p->next != NULL; p = p->next, ++size );
  return size;
}

template<class Object>
void SList<Object>::clear( ) {
  for ( int i = 0; i < LEVEL; i++ ) {        // for each level
    SListNode<Object> *p = header[i]->next;  // get the 1st item
    while ( p->next != NULL ) {              // if this is not the left most
      SListNode<Object> *del = p;
      p = p->next;                           // get the next item
      delete del;                            // delete the current item
    }

    header[i]->next = p;                     // p now points to the left most
  }                                          // let the right most point to it
}

template<class Object>
void SList<Object>::insert( const Object &obj ) {
  // right points to the level-0 item before which a new object is inserted.
  SListNode<Object> *right = searchPointer( obj );

  if ( right->next != NULL && right->item == obj )
    // there is an identical object
    return;

  SListNode<Object> *cur = new SListNode<Object>(); //Our original node that is inserted on the bottom
  //Set the pointers for the node and the node to the left and right of it to the node cur
  cur->item = obj;
  cur->next = right;
  cur->prev = right->prev;
  right->prev->next = cur;
  right->prev = cur;
  cur->up = NULL;
  cur->down = NULL;

  //Now roll the dice and see how far up the tree we are going to add the new node
  int level = 0;
  int random = rand() % 2;
  while((random == 1) && (level != (LEVEL-1))) {

	  // Set it to the previous value, we know the current doesn't have an up
	  // This pointer navigates to where we want to put the new node
	  SListNode<Object> *navPointer = cur->prev;

	  // Check if the current node has an up, if not keep going till we find one that does
	  while(navPointer->up == NULL) {
		  navPointer = navPointer->prev;
	  }
	  // Go up to the top node and create the node we will be inserting on the upper level
	  navPointer = navPointer->up;
	  SListNode<Object> *addNode = new SListNode<Object>();
      // Set the new nodes pointers
	  addNode->item = obj;
	  addNode->next = navPointer->next;
	  addNode->prev = navPointer;
	  // Align the new node we created to be pointed to by the existing nodes
	  navPointer->next->prev = addNode;
	  navPointer->next = addNode;
      // Set the original node to point up to the new node created
      cur->up = addNode;
      addNode->down = cur;
      addNode->up = NULL;
      // Set the pointer on the new node and roll the dice again
      cur = addNode;
      navPointer = addNode;
      random = rand() % 2;
      level++;
  }

}

template<class Object>
bool SList<Object>::find( const Object &obj ) {
  // p oints to the level-0 item close to a given object
  SListNode<Object> *p = searchPointer( obj );

  return ( p->next != NULL && p->item == obj );     // true if obj was found
}

template<class Object>
SListNode<Object> *SList<Object>::searchPointer( const Object &obj ) {
  SListNode<Object> *p = header[LEVEL - 1];     // start from the top left
  while ( p->down != NULL ) {                   // toward level 0
    p = p->down;                                // shift down once
    cost++;

    if ( p->prev == NULL ) {                    // at the left most item
      if ( p->next->next == NULL )              // no intermediate items
        continue;
      else {                                    // some intermadiate items
        if ( p->next->item <= obj )             // if 1st item <= obj
          p = p->next;                          // shift right to item 1
        cost++;
      }
    }

    while ( p->next->next != NULL && p->next->item <= obj ) {
      // shift right through intermediate items as far as the item value <= obj
      p = p->next;
      cost++;
    }
  }

  // now reached the bottom. shift right once if the current item < obj
  if ( p->prev == NULL || p->item < obj ) {
    p = p->next;
    cost++;
  }
  return p; // return the pointer to an item >= a given object.
}

template<class Object>
void SList<Object>::remove( const Object &obj ) {
  // p points to the level-0 item to delete
  SListNode<Object> *p = searchPointer( obj );

  // validate if p is not the left most or right most and exactly contains the
  // item to delete
  if ( p->prev == NULL || p->next == NULL || p->item != obj )
    return;
  bool hasTop = true; //Sets to true so we go through at least once in case it has no top
  while(hasTop == true) { //Check if we have gotten to the top of the list
	  p->prev->next = p->next; // Assign the previous values next to the value after the one we are deleting
	  p->next->prev = p->prev; // Assign the next value's previous to the value before the one we are deleting
	  if(p->up == NULL) { // If there is no up then delete it
		  hasTop = false;
		  delete p;
	  } else { // There is an up, increase to the next node, delete the one below it
		  p = p->up;
		  delete p->down;
	  }
  }
}

template<class Object>
const SList<Object> &SList<Object>::operator=( const SList &rhs ) {
  if ( this != &rhs ) { // avoid self-assignment
    clear( );           // deallocate old items

    int index;
    SListNode<Object> *rnode;
    for ( index = 0, rnode = rhs.header[0]->next; rnode->next != NULL;
	  rnode = rnode->next, ++index )
      insert( rnode->item );

    cost = rhs.cost;
  }
  return *this;
}

template<class Object>
int SList<Object>::getCost( ) const {
  return cost;
}

template<class Object>
void SList<Object>::show( ) const {
  cout << "contents:" << endl;
  for ( SListNode<Object> *col = header[0]; col != NULL; col = col->next ) {
    SListNode<Object> *row = col;
    for ( int level = 0; row != NULL && level < LEVEL; level++ ) {
      if ( row->prev == NULL )
	cout << "-inf\t";
      else if ( row->next == NULL )
	cout << "+inf\t";
      else
	cout << row->item << "\t";
      row = row->up;
    }
    cout << endl;
  }
}
