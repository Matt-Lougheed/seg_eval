#include "itkImage.h"
#include "itkImageFileReader.h"
#include "itkImageFileWriter.h"
#include "itkLabelOverlapMeasuresImageFilter.h"

int main(int argc, char *argv[])
{
  // Check command line arguments
  if (argc < 4)
    {
      std::cerr << "Usage: " << std::endl;
      std::cerr << argv[0] << " firstImageFileName secondImageFileName outputFileName" << std::endl;
      return EXIT_FAILURE;
    }

  typedef itk::Image<unsigned char, 3> ImageType;
  typedef itk::ImageFileReader<ImageType> ReaderType;
  typedef itk::LabelOverlapMeasuresImageFilter<ImageType> FilterType;

  ReaderType::Pointer reader1 = ReaderType::New();
  ReaderType::Pointer reader2 = ReaderType::New();

  std::string outputFileName = argv[3];
  
  // Read first image
  reader1->SetFileName(argv[1]);
  reader1->Update();

  // Read second image
  reader2->SetFileName(argv[2]);
  reader2->Update();

  // Compute overlap
  FilterType::Pointer diceCoefficientFilter = FilterType::New();
  diceCoefficientFilter->SetSourceImage(reader1->GetOutput());
  diceCoefficientFilter->SetTargetImage(reader2->GetOutput());
  diceCoefficientFilter->Update();

  // Write to output
  std::ofstream outputFile;
  outputFile.open(outputFileName.c_str(), std::ios::app);
  outputFile << "Dice " << diceCoefficientFilter->GetTotalOverlap() << std::endl;
  outputFile.close();

  return EXIT_SUCCESS;
}
