#include "itkObject.h"
#include "itkImage.h"
#include "itkImageFileReader.h"
#include "itkImageFileWriter.h"
#include "itkHausdorffDistanceImageFilter.h"

int main(int argc, char *argv[])
{
  // Check command line arguments
  if (argc < 3)
    {
      std::cerr << "Usage: " << std::endl;
      std::cerr << argv[0] << " firstImageFileName secondImageFileName" << std::endl;
      return EXIT_FAILURE;
    }

  typedef itk::Image<unsigned char, 3> ImageType;
  typedef itk::ImageFileReader<ImageType> ReaderType;
  typedef itk::HausdorffDistanceImageFilter<ImageType, ImageType> FilterType;
  
  ReaderType::Pointer reader1 = ReaderType::New();
  ReaderType::Pointer reader2 = ReaderType::New();
  
  // Read first image
  reader1->SetFileName(argv[1]);
  reader1->Update();
  ImageType::Pointer image1 = reader1->GetOutput();
  
  // Read second image
  reader2->SetFileName(argv[2]);
  reader2->Update();
  ImageType::Pointer image2 = reader2->GetOutput();

  // Compute hausdorff distance
  FilterType::Pointer hausdorffFilter = FilterType::New();
  hausdorffFilter->SetInput1(reader1->GetOutput());
  hausdorffFilter->SetInput2(reader2->GetOutput());
  hausdorffFilter->Update();

  // Print result
  std::cout << "Hausdorff Distance: " << hausdorffFilter->GetHausdorffDistance() << std::endl;

  return hausdorffFilter->GetHausdorffDistance();
}
