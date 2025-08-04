# Project Context Feature

## Overview
The Project Context feature provides a comprehensive system for managing project-specific information, context questions, and documents. This feature enhances AI-powered task generation by providing rich context about the project requirements, constraints, and resources.

## Features

### 🔍 **Context Icon in Project Tile**
- **Smart Visual Indicator**: A book/library icon appears in the current project tile
- **Dynamic State**: Icon color changes based on context availability:
  - Purple: Context is available 
  - Gray: No context available
- **Content Badge**: Shows the total number of context items (questions + documents)
- **Intuitive Access**: Single tap opens the detailed context screen

### 📋 **Context Questions Management**
- **Categorized Questions**: Questions organized by type:
  - Project Scope
  - Technical Requirements  
  - Timeline
  - Resources
  - Constraints
  - Other
- **Rich Answer Support**: Multi-line text answers with timestamps
- **Required Questions**: Mark critical questions as required
- **Edit Capability**: Update answers as project evolves
- **AI Summary**: Automatic AI-generated project summary based on answers

### 📁 **Document Management**
- **Multi-format Support**: Upload PDFs, images, documents, designs, etc.
- **Document Types**: Organized by categories:
  - Requirements
  - Design
  - Specification  
  - Reference
  - Assets
  - Other
- **Smart Metadata**: File size, upload date, uploader tracking
- **File Icons**: Context-aware icons based on file type
- **Document Actions**: View, download, and remove options

### 🎨 **Design Integration**
- **Neumorphic Design**: Consistent with existing app design language
- **Responsive Layout**: Optimized for mobile-first experience
- **Smooth Animations**: Polished transitions and micro-interactions
- **Accessibility**: Screen reader support and proper contrast ratios

## Technical Architecture

### Data Models

#### `ProjectContext`
```dart
class ProjectContext {
  final String projectId;
  final List<ContextQuestion> contextQuestions;
  final List<ProjectDocument> documents;  
  final DateTime lastUpdated;
  final String? summary; // AI-generated summary
}
```

#### `ContextQuestion`
```dart
class ContextQuestion {
  final String question;
  final String answer;
  final ContextQuestionType type;
  final DateTime answeredAt;
  final bool isRequired;
}
```

#### `ProjectDocument`  
```dart
class ProjectDocument {
  final String name;
  final String path;
  final String mimeType;
  final int sizeInBytes;
  final DocumentType type;
  final String? description;
}
```

### State Management
- **Riverpod Provider**: `projectContextNotifierProvider`
- **Async State Handling**: Loading, success, and error states
- **Real-time Updates**: Automatic UI updates when context changes
- **Optimistic Updates**: Immediate UI feedback for better UX

### File Structure
```
lib/features/project_context/
├── models/
│   └── project_context_model.dart
├── providers/
│   └── project_context_provider.dart
├── presentation/
│   └── project_context_screen.dart
└── README.md
```

## User Experience Flow

### 1. **Discovery**
- User sees context icon in project tile
- Badge indicates available content count
- Icon color shows context availability

### 2. **Access**  
- Single tap opens context screen
- Loading states provide feedback
- Error handling with retry options

### 3. **Context Screen**
- **Header**: Project title and add button
- **AI Summary**: Quick project overview (if available)
- **Tabbed Interface**: 
  - Questions tab with categorized Q&A
  - Documents tab with organized files
- **Empty States**: Encouraging prompts when no content

### 4. **Content Management**
- **Add Menu**: Bottom sheet with options
- **Question Dialog**: (To be implemented)
- **File Upload**: Native file picker integration
- **Edit Actions**: Contextual menus for modifications

## Integration Points

### AI Task Generation
- Context questions provide project understanding
- Documents offer detailed requirements
- Summary gives quick project overview
- All data feeds into Claude AI for better task generation

### Project Management
- Context icon in project selection tile
- Real-time content count updates
- Seamless navigation between context and tasks

### Document Storage
- Placeholder for cloud storage integration
- File metadata tracking
- Version control preparation

## Implementation Details

### Context Icon Button
```dart
Widget _buildProjectContextButton(Project project) {
  return Consumer(
    builder: (context, ref, child) {
      final contextAsync = ref.watch(projectContextNotifierProvider(project.id));
      
      return contextAsync.when(
        data: (context) => NeumorphicButton(
          child: Stack(
            children: [
              Icon(Icons.library_books_outlined),
              if (context?.hasContent ?? false)
                Badge(count: context!.totalItems),
            ],
          ),
        ),
        loading: () => LoadingButton(),
        error: (_, __) => ErrorButton(),
      );
    },
  );
}
```

### Context Screen Architecture
- **StatefulWidget** with TabController
- **Consumer** for reactive state management  
- **Responsive design** with ScreenUtil
- **Modular widgets** for maintainability

## Future Enhancements

### Phase 1 Completed ✅
- Context icon in project tile
- Basic context screen with tabs
- Document upload functionality
- Question display system

### Phase 2 (Planned)
- [ ] Add/Edit question dialogs
- [ ] Advanced file management
- [ ] Context search functionality
- [ ] Export context as PDF

### Phase 3 (Future)
- [ ] AI-powered question suggestions
- [ ] Document OCR and parsing
- [ ] Team collaboration on context
- [ ] Integration with external tools

## Benefits

### For Users
- **Better AI Results**: Rich context improves task generation
- **Organized Information**: Centralized project knowledge
- **Easy Access**: Quick context review and updates
- **Visual Feedback**: Clear indication of context availability

### For AI
- **Rich Context**: Detailed project understanding
- **Structured Data**: Organized information for processing
- **Continuous Learning**: Updated context improves recommendations
- **Multi-modal Input**: Text + documents for comprehensive understanding

### For Project Management
- **Knowledge Retention**: Project information preserved
- **Team Alignment**: Shared understanding of requirements
- **Progress Tracking**: Context evolution over time
- **Documentation**: Automatic project documentation

## Usage Examples

### Adding Context to New Project
1. Create project through normal flow
2. Notice empty context icon in project tile  
3. Tap icon to open context screen
4. Add questions and upload documents
5. Watch icon update with content badge

### Using Context for AI Tasks
1. Project with rich context gets better AI suggestions
2. Document content influences task generation
3. Question answers provide constraints and requirements
4. Summary gives AI quick project understanding

### Team Collaboration
1. Team member uploads requirement document
2. Another member answers technical questions
3. Context automatically updates for all users
4. AI uses combined knowledge for better results

## Technical Notes

### Performance Considerations
- Lazy loading of context data
- Efficient file upload with progress
- Caching for frequently accessed content
- Optimistic updates for responsive UI

### Security & Privacy  
- Secure file upload endpoints
- User permission checks
- Data encryption in transit
- GDPR compliance for document storage

### Scalability
- Modular architecture for easy extension
- Provider pattern for state management
- Extensible document type system
- Flexible question categorization

This feature significantly enhances the ProjectFlow AI experience by providing the AI system with rich, structured context about each project, leading to more accurate and relevant task generation and project management assistance.