template<class Object>
int MtfList<Object>::find(const Object &obj) {
	DListNode<Object> *top = DList<Object>::header->next;
	DListNode<Object> *found = top;

	for (; found != NULL && found->item != obj; found = found->next)
		++DList<Object>::cost;

	if (found == NULL)
		return -1; // not found

	if (found == top)
		return 0;  // no need to move to front
//	if (found->next == NULL) {
//		found->prev = NULL;
//	}

	found->prev->next = found->next;
	if (found->next != NULL) {
		found->next->prev = found->prev;
	}
	found->next = top;
	found->prev = top->prev;
	top->prev = found;
	found->prev->next = found;
	found->next->prev = found;

	cout << "top->next->item = " << found->next->item
			<< "top->next->next->item = " << found->next->next->item << endl;
	// remove found from the current position
	// insert found between header and top

	return 0;

}
