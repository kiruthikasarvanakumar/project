#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <string.h>
#include <errno.h>
#include <limits.h>

// Node structure for stack
struct Node {
    	char dir[PATH_MAX];
 	struct Node* next;
};

// Push a directory onto the stack
void push(struct Node** stack, const char* dir) {
	struct Node* newNode = (struct Node*)malloc(sizeof(struct Node));
	if (newNode == NULL) {
		perror("malloc");
		exit(EXIT_FAILURE);
	}
	strncpy(newNode->dir, dir, PATH_MAX);
	newNode->next = *stack;
	*stack = newNode;
}
// Pop a directory from the stack
void pop(struct Node** stack, char* dir) {
	if (*stack == NULL) {
		fprintf(stderr, "popd: directory stack empty\n");
		exit(EXIT_FAILURE);
	}
	struct Node* temp = *stack;
	strncpy(dir, temp->dir, PATH_MAX);
	*stack = (*stack)->next;
	free(temp);
	printf("Popped: %s\n", dir);
}                                                                         
// Change directory and handle errors
void changeDir(const char* dir) {
	if (chdir(dir) != 0) {
		perror("chdir");
		exit(EXIT_FAILURE);
	}
}
int main(int argc, char* argv[]) {
	static struct Node* dirStack = NULL;
	char cwd[PATH_MAX];
	if (argc < 2) {
		fprintf(stderr, "Usage: %s [pushd <dir> | popd]\n", argv[0]);
		exit(EXIT_FAILURE);
	}
	if (strcmp(argv[1], "pushd") == 0) {
		if (argc != 3) {
			fprintf(stderr, "Usage: %s pushd <dir>\n", argv[0]);
			exit(EXIT_FAILURE);
		}
		if (getcwd(cwd, sizeof(cwd)) == NULL) {
			perror("getcwd");
			exit(EXIT_FAILURE);
		}
		push(&dirStack, cwd);
		changeDir(argv[2]);
	} else if (strcmp(argv[1], "popd") == 0) {
		if (argc != 2) {
			fprintf(stderr, "Usage: %s popd\n", argv[0]);
			exit(EXIT_FAILURE);
		}
		pop(&dirStack, cwd);
		changeDir(cwd);
	} else {
		fprintf(stderr, "Unknown command: %s\n", argv[1]);
		exit(EXIT_FAILURE);
	}
	if (getcwd(cwd, sizeof(cwd)) == NULL) {
		perror("getcwd");
		exit(EXIT_FAILURE);
	}
	printf("Current directory: %s\n", cwd);
	return 0;
}
