import { useMutation, UseMutationOptions } from "react-query";
import { axiosInstance } from "@/utils/url";
import { venueURL } from "@/utils/url/venue";
import { Venue } from "@/type";
import { AxiosError } from "axios";
import { jsonHeader } from "@/utils/url/header";

export interface CreateVenueRequest {
  name: string;
  address?: string;
  tel?: string;
  description?: string;
  capacity?: number;
  facilities?: string;
  availableTime?: string;
  imageUrl?: string;
}

const postVenue = async (body: CreateVenueRequest) => {
  const headers = await jsonHeader;
  const response = await axiosInstance.post(venueURL, body, {
    headers,
  });
  return response.data;
};

export const useAPIPostVenue = (
  mutationOptions?: UseMutationOptions<Venue, AxiosError, CreateVenueRequest>
) => {
  return useMutation<Venue, AxiosError, CreateVenueRequest>(
    postVenue,
    mutationOptions
  );
};
